require 'spec_helper'

module Arel
  describe Join do
    before do
      @relation1 = Table.new(:users)
      @relation2 = Table.new(:photos)
      @predicate1 = @relation1[:id].eq(@relation2[:user_id])

      @relation3 = Table.new(:users, :as => :super_users)
      @relation4 = Table.new(:photos, :as => :super_photos)

      @predicate2 = @relation3[:id].eq(@relation2[:user_id])
      @predicate3 = @relation3[:id].eq(@relation4[:user_id])
    end

    describe '#to_sql' do

      describe 'when joining with another relation' do
        it 'manufactures sql joining the two tables on the predicate' do
          sql = InnerJoin.new(@relation1, @relation2, @predicate1).to_sql

          adapter_is :mysql do
            sql.should be_like(%Q{
              SELECT `users`.`id`, `users`.`name`, `photos`.`id`, `photos`.`user_id`, `photos`.`camera_id`
              FROM `users`
                INNER JOIN `photos` ON `users`.`id` = `photos`.`user_id`
            })
          end

          adapter_is_not :mysql do
            sql.should be_like(%Q{
              SELECT "users"."id", "users"."name", "photos"."id", "photos"."user_id", "photos"."camera_id"
              FROM "users"
                INNER JOIN "photos" ON "users"."id" = "photos"."user_id"
            })
          end
        end

        describe 'when joining with another relation with an aliased table' do
          it 'manufactures sql joining the two tables on the predicate respecting table aliasing' do
            sql = InnerJoin.new(@relation3, @relation2, @predicate2).to_sql

            adapter_is :mysql do
              sql.should be_like(%Q{
                SELECT `super_users`.`id`, `super_users`.`name`, `photos`.`id`, `photos`.`user_id`, `photos`.`camera_id`
                FROM `users` AS `super_users`
                  INNER JOIN `photos` ON `super_users`.`id` = `photos`.`user_id`
              })
            end

            adapter_is_not :mysql do
              sql.should be_like(%Q{
                SELECT "super_users"."id", "super_users"."name", "photos"."id", "photos"."user_id", "photos"."camera_id"
                FROM "users" AS "super_users"
                  INNER JOIN "photos" ON "super_users"."id" = "photos"."user_id"
              })
            end
          end
        end

        describe 'when joining with two relations with aliased tables' do
          it 'manufactures sql joining the two tables on the predicate respecting table aliasing' do
            sql = InnerJoin.new(@relation3, @relation4, @predicate3).to_sql

            adapter_is :mysql do
              sql.should be_like(%Q{
                SELECT `super_users`.`id`, `super_users`.`name`, `super_photos`.`id`, `super_photos`.`user_id`, `super_photos`.`camera_id`
                FROM `users` AS `super_users`
                  INNER JOIN `photos` AS `super_photos` ON `super_users`.`id` = `super_photos`.`user_id`
              })
            end

            adapter_is_not :mysql do
              sql.should be_like(%Q{
                SELECT "super_users"."id", "super_users"."name", "super_photos"."id", "super_photos"."user_id", "super_photos"."camera_id"
                FROM "users" AS "super_users"
                  INNER JOIN "photos" AS "super_photos" ON "super_users"."id" = "super_photos"."user_id"
              })
            end
          end
        end

      end

      describe 'when joining with a string' do
        it "passes the string through to the where clause" do
          sql = StringJoin.new(@relation1, "INNER JOIN asdf ON fdsa").to_sql

          adapter_is :mysql do
            sql.should be_like(%Q{
              SELECT `users`.`id`, `users`.`name`
              FROM `users`
                INNER JOIN asdf ON fdsa
            })
          end

          adapter_is_not :mysql do
            sql.should be_like(%Q{
              SELECT "users"."id", "users"."name"
              FROM "users"
                INNER JOIN asdf ON fdsa
            })
          end
        end
      end
    end
  end
end
