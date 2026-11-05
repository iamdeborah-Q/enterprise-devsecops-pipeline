package main

import rego.v1

instructions := input

final_stage := max([i.Stage | some i in instructions; i.Cmd == "from"])

deny contains msg if {
    some i in instructions
    i.Cmd == "from"
    endswith(lower(i.Value[0]), ":latest")
    msg := "Docker images must not use the latest tag"
}

deny contains msg if {
    not nonroot_final_user
    msg := "Final production stage must specify a non-root USER"
}

nonroot_final_user if {
    some i in instructions
    i.Stage == final_stage
    i.Cmd == "user"
    user := lower(i.Value[0])
    user != "root"
    user != "0"
}

deny contains msg if {
    some i in instructions
    i.Cmd == "add"
    msg := "Use COPY instead of ADD"
}
