resource "kubernetes_manifest" "customresourcedefinition_scrollsports_demeter_run" {
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "scrollsports.demeter.run"
    }
    "spec" = {
      "group" = "demeter.run"
      "names" = {
        "categories" = [
          "demeter-port",
        ]
        "kind" = "ScrollsPort"
        "plural" = "scrollsports"
        "shortNames" = [
          "spts",
        ]
        "singular" = "scrollsport"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.network"
              "name" = "Network"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.throughputTier"
              "name" = "Throughput Tier"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.endpointUrl"
              "name" = "Endpoint URL"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.authenticatedEndpointUrl"
              "name" = "Authenticated Endpoint URL"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.authToken"
              "name" = "Auth Token"
              "type" = "string"
            },
          ]
          "name" = "v1alpha1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "Auto-generated derived type for ScrollsPortSpec via `CustomResource`"
              "properties" = {
                "spec" = {
                  "properties" = {
                    "authToken" = {
                      "nullable" = true
                      "type" = "string"
                    }
                    "network" = {
                      "type" = "string"
                    }
                    "operatorVersion" = {
                      "type" = "string"
                    }
                    "throughputTier" = {
                      "type" = "string"
                    }
                    "version" = {
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "network",
                    "operatorVersion",
                    "throughputTier",
                    "version",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "nullable" = true
                  "properties" = {
                    "authToken" = {
                      "type" = "string"
                    }
                    "authenticatedEndpointUrl" = {
                      "nullable" = true
                      "type" = "string"
                    }
                    "endpointUrl" = {
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "authToken",
                    "endpointUrl",
                  ]
                  "type" = "object"
                }
              }
              "required" = [
                "spec",
              ]
              "title" = "ScrollsPort"
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}
