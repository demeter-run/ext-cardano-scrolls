use kube::CustomResourceExt;

fn main() {
    print!(
        "{}",
        serde_yaml::to_string(&operator::ScrollsPort::crd()).unwrap()
    )
}
