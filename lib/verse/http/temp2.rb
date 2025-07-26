# frozen_string_literal: true

require "roda"

class Server < Roda
  route do |r|
    r.get do
      puts "Match #{r.path}"
    end

    r.on "users" do
      r.get do
        puts "Match #{r.path}"
      end
      r.post do
        puts "Match #{r.path}"
      end

      r.on "info" do
        r.get do
          puts "Match #{r.path}"
        end
      end

      r.on String do |value|
        r.params["id"] = value
        r.get do
          puts "Match #{r.path}"
        end
        r.put do
          puts "Match #{r.path}"
        end
        r.delete do
          puts "Match #{r.path}"
        end
      end
    end
    r.on "posts" do
      r.get do
        puts "Match #{r.path}"
      end
      r.post do
        puts "Match #{r.path}"
      end
      r.on String do |value|
        r.params["id"] = value
        r.get do
          puts "Match #{r.path}"
        end
        r.put do
          puts "Match #{r.path}"
        end
        r.delete do
          puts "Match #{r.path}"
        end
      end
      r.on String do |value|
        r.params["post_id"] = value
        r.on "comments" do
          r.get do
            puts "Match #{r.path}"
          end
          r.post do
            puts "Match #{r.path}"
          end
          r.on String do |value|
            r.params["id"] = value
            r.get do
              puts "Match #{r.path}"
            end
            r.put do
              puts "Match #{r.path}"
            end
            r.delete do
              puts "Match #{r.path}"
            end
          end
        end
      end
    end
    r.on "_service" do
      r.get do
        puts "Match #{r.path}"
      end
    end
  end
end

run App.freeze.app