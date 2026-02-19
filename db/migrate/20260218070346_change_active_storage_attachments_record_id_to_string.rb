class ChangeActiveStorageAttachmentsRecordIdToString < ActiveRecord::Migration[8.1]
  def change
    ActiveStorage::VariantRecord.delete_all
    ActiveStorage::Attachment.delete_all
    ActiveStorage::Blob.delete_all

    execute <<~SQL
      ALTER TABLE active_storage_attachments
      ALTER COLUMN record_id TYPE uuid USING record_id::text::uuid
    SQL
  end
end
