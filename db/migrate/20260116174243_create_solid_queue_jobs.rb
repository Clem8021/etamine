class CreateSolidQueueJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string   :queue_name
      t.string   :active_job_id
      t.text     :serialized
      t.datetime :run_at
      t.integer  :attempts, default: 0
      t.timestamps
    end
  end
end
