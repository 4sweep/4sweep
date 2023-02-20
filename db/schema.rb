# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2014_07_05_230607) do

  create_table "categories_caches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "categories", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.timestamp "last_verified"
    t.string "digest"
    t.index ["created_at"], name: "index_categories_caches_on_created_at"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "flags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "type"
    t.string "status", default: "new"
    t.string "venueId"
    t.integer "user_id"
    t.string "secondaryVenueId"
    t.string "primaryName"
    t.string "secondaryName"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "problem"
    t.timestamp "submitted_at"
    t.string "resolved_details"
    t.timestamp "last_checked"
    t.string "itemId"
    t.string "itemName"
    t.string "comment"
    t.integer "job_id"
    t.datetime "scheduled_at"
    t.text "edits"
    t.string "creatorId"
    t.string "creatorName"
    t.text "venues_details"
    t.index ["secondaryVenueId"], name: "index_flags_on_secondaryVenueId"
    t.index ["status"], name: "index_flags_on_status"
    t.index ["user_id", "status", "created_at"], name: "index_flags_on_user_id_and_status_and_created_at"
    t.index ["user_id", "status", "creatorId", "type"], name: "index_flags_on_user_id_and_status_and_creatorId_and_type"
    t.index ["user_id", "status", "secondaryVenueId", "type"], name: "index_flags_on_user_id_and_status_and_secondaryVenueId_and_type"
    t.index ["user_id", "status", "venueId", "type"], name: "index_flags_on_user_id_and_status_and_venueId_and_type"
    t.index ["venueId"], name: "index_flags_on_venueId"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "level"
    t.string "token"
    t.boolean "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "uid"
    t.text "user_cache", limit: 16777215
    t.timestamp "cached_at"
    t.string "hometown"
    t.index ["token"], name: "index_users_on_token"
    t.index ["uid"], name: "index_users_on_uid"
  end

end
