package kubernetes.security

test_deny_no_memory_limits {
  deny[_] with input as {
    "kind": "Deployment",
    "spec": {
      "template": {
        "spec": {
          "containers": [{
            "name": "test",
            "image": "nginx"
          }]
        }
      }
    }
  }
}

test_allow_with_limits {
  count(deny) == 0 with input as {
    "kind": "Deployment",
    "spec": {
      "template": {
        "spec": {
          "containers": [{
            "name": "test",
            "image": "nginx",
            "resources": {
              "limits": {
                "memory": "128Mi",
                "cpu": "100m"
              }
            },
            "securityContext": {
              "runAsNonRoot": true
            },
            "readinessProbe": {
              "httpGet": {
                "path": "/",
                "port": 80
              }
            }
          }]
        }
      }
    }
  }
}
