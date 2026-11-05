
package main

import rego.v1

workloads := {"Deployment", "StatefulSet", "DaemonSet", "Job", "Pod"}

containers := [c |
    input.kind in workloads
    spec := object.get(input, "spec", {})
    template := object.get(spec, "template", {})
    pod_spec := object.get(template, "spec", spec)
    c := pod_spec.containers[_]
]

deny contains msg if {
    c := containers[_]
    ctx := object.get(c, "securityContext", {})
    object.get(ctx, "runAsNonRoot", false) != true
    msg := sprintf("Container %s must run as non-root", [c.name])
}

deny contains msg if {
    c := containers[_]
    ctx := object.get(c, "securityContext", {})
    object.get(ctx, "allowPrivilegeEscalation", true) != false
    msg := sprintf("Container %s must disable privilege escalation", [c.name])
}

deny contains msg if {
    c := containers[_]
    ctx := object.get(c, "securityContext", {})
    capabilities := object.get(ctx, "capabilities", {})
    dropped := object.get(capabilities, "drop", [])
    not "ALL" in dropped
    msg := sprintf("Container %s must drop all Linux capabilities", [c.name])
}

deny contains msg if {
    c := containers[_]
    resources := object.get(c, "resources", {})
    limits := object.get(resources, "limits", {})
    not object.get(limits, "memory", "")
    msg := sprintf("Container %s must define a memory limit", [c.name])
}

deny contains msg if {
    c := containers[_]
    resources := object.get(c, "resources", {})
    requests := object.get(resources, "requests", {})
    not object.get(requests, "cpu", "")
    msg := sprintf("Container %s must define a CPU request", [c.name])
}

deny contains msg if {
    c := containers[_]
    image := object.get(c, "image", "")
    endswith(image, ":latest")
    msg := sprintf("Container %s must not use the latest image tag", [c.name])
}

deny contains msg if {
    c := containers[_]
    ctx := object.get(c, "securityContext", {})
    object.get(ctx, "privileged", false) == true
    msg := sprintf("Container %s must not run in privileged mode", [c.name])
}
