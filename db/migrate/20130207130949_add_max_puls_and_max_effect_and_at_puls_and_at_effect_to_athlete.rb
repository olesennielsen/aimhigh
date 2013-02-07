class AddMaxPulsAndMaxEffectAndAtPulsAndAtEffectToAthlete < ActiveRecord::Migration
  def change
    add_column :athletes, :max_puls, :int
    add_column :athletes, :max_effect, :int
    add_column :athletes, :at_puls, :int
    add_column :athletes, :at_effect, :int
  end
end
