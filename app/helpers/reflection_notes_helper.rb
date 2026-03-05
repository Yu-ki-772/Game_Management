# app/helpers/reflection_notes_helper.rb
module ReflectionNotesHelper
  def reflection_type_color_class(reflection_type)
    type_colors = {
      "success"     => "bg-emerald-100 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-400",
      "improvement" => "bg-amber-100 dark:bg-amber-900/40 text-amber-700 dark:text-amber-400",
      "hypothesis"  => "bg-sky-100 dark:bg-sky-900/40 text-sky-700 dark:text-sky-400"
    }

    type_colors.fetch(reflection_type.to_s,
      "bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400")
  end
end
