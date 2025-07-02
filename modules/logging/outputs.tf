output "writer_identity" {
  description = "The service account email address that logging uses to write log entries to the destination. This account must be granted permissions to the destination."
  value = coalesce(
    one(google_logging_organization_sink.org_sink[*].writer_identity),
    one(google_logging_folder_sink.folder_sink[*].writer_identity),
    one(google_logging_project_sink.project_sink[*].writer_identity)
  )
}

output "sink_id" {
  description = "The ID of the created log sink."
  value = coalesce(
    one(google_logging_organization_sink.org_sink[*].id),
    one(google_logging_folder_sink.folder_sink[*].id),
    one(google_logging_project_sink.project_sink[*].id)
  )
}
