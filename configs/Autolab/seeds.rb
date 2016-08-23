# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.create!(email: "admin@foo.bar",
                    first_name: "Test",
                    last_name: "User",
                    password: "12345678",
                    confirmed_at:DateTime.now,
                    administrator: true
                    )
user.skip_confirmation!

