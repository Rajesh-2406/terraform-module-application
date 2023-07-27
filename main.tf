resource  "null_resource" "test"{
  provosiner  "local=exec" {
    command = "echo Hello World - env - $(variable.env")
  }
}