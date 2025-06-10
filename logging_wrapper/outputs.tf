output "log_sink_details" {
  description = "Details of the created log sinks, including their IDs and writer identities."
  value = {
    for k, sink_module in module.logging_sinks : k => {
      #id              = sink_module.id
      writer_identity = sink_module.writer_identity
    }
  }
}