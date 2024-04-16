use futures::StreamExt;
use kube::{
    runtime::{controller::Action, watcher::Config as WatcherConfig, Controller},
    Api, Client, CustomResource, CustomResourceExt, ResourceExt,
};
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use std::{sync::Arc, time::Duration};
use tracing::{error, info, instrument};

use crate::{build_api_key, build_hostname, patch_resource_status, Error, Metrics, Result, State};

pub static SCROLLS_PORT_FINALIZER: &str = "scrollsports.demeter.run";

struct Context {
    pub client: Client,
    pub metrics: Metrics,
}
impl Context {
    pub fn new(client: Client, metrics: Metrics) -> Self {
        Self { client, metrics }
    }
}

#[derive(CustomResource, Deserialize, Serialize, Clone, Debug, JsonSchema)]
#[kube(
    kind = "ScrollsPort",
    group = "demeter.run",
    version = "v1alpha1",
    shortname = "spts",
    category = "demeter-port",
    namespaced
)]
#[kube(status = "ScrollsPortStatus")]
#[kube(printcolumn = r#"
        {"name": "Network", "jsonPath": ".spec.network", "type": "string"},
        {"name": "Throughput Tier", "jsonPath":".spec.throughputTier", "type": "string"}, 
        {"name": "Endpoint URL", "jsonPath": ".status.endpointUrl", "type": "string"},
        {"name": "Authenticated Endpoint URL", "jsonPath": ".status.authenticatedEndpointUrl", "type": "string"},
        {"name": "Auth Token", "jsonPath": ".status.authToken", "type": "string"}
    "#)]
#[serde(rename_all = "camelCase")]
pub struct ScrollsPortSpec {
    pub operator_version: String,
    pub network: String,
    pub throughput_tier: String,
    pub version: String,
}

#[derive(Deserialize, Serialize, Clone, Default, Debug, JsonSchema)]
#[serde(rename_all = "camelCase")]
pub struct ScrollsPortStatus {
    pub endpoint_url: String,
    pub authenticated_endpoint_url: Option<String>,
    pub auth_token: String,
}

async fn reconcile(crd: Arc<ScrollsPort>, ctx: Arc<Context>) -> Result<Action> {
    let key = build_api_key(&crd).await?;
    let (hostname, hostname_key) = build_hostname(&key);

    let status = ScrollsPortStatus {
        endpoint_url: format!("https://{hostname}",),
        authenticated_endpoint_url: format!("https://{hostname_key}").into(),
        auth_token: key,
    };

    let namespace = crd.namespace().unwrap();
    let scrolls_port = ScrollsPort::api_resource();

    patch_resource_status(
        ctx.client.clone(),
        &namespace,
        scrolls_port,
        &crd.name_any(),
        serde_json::to_value(status)?,
    )
    .await?;

    info!(resource = crd.name_any(), "Reconcile completed");

    Ok(Action::await_change())
}

fn error_policy(crd: Arc<ScrollsPort>, err: &Error, ctx: Arc<Context>) -> Action {
    error!(error = err.to_string(), "reconcile failed");
    ctx.metrics.reconcile_failure(&crd, err);
    Action::requeue(Duration::from_secs(5))
}

#[instrument("controller run", skip_all)]
pub async fn run(state: Arc<State>) {
    info!("listening crds running");

    let client = Client::try_default()
        .await
        .expect("failed to create kube client");

    let crds = Api::<ScrollsPort>::all(client.clone());

    let ctx = Context::new(client, state.metrics.clone());

    Controller::new(crds, WatcherConfig::default().any_semantic())
        .shutdown_on_signal()
        .run(reconcile, error_policy, Arc::new(ctx))
        .filter_map(|x| async move { std::result::Result::ok(x) })
        .for_each(|_| futures::future::ready(()))
        .await;
}
