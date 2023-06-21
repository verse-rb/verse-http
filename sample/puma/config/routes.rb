# frozen_string_literal: true

Verse.on_boot do
  # Include the exposition after Verse has been initialized
  Expo.register
end
