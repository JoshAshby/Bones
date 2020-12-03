# frozen_string_literal: true

# rubocop:disable Layout/LineLength
forme_inputs = {
  default: "max-w-lg block w-full shadow-inner focus:ring-steelblue-500 focus:border-steelblue-500 sm:max-w-xs sm:text-sm border-gray-300 rounded-md",
  button: "cursor-pointer bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-steelblue-500",
  submit: "cursor-pointer ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-steelblue-600 hover:bg-steelblue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-steelblue-500",
  reset: "cursor-pointer"
}

Forme.register_transformer(:formatter, :sidebyside) do |input|
  input.opts[:class] ||= forme_inputs.fetch input.type, forme_inputs[:default]
  # Forme.attr_classes input.opts, forme_inputs.fetch(input.type, forme_inputs[:default])

  # puts
  # puts "-------------- formatter (#{ input.type }) ------------"
  # puts input.opts

  # puts caller.first

  Forme::Formatter.new.call input
end

Forme.register_transformer(:labeler, :sidebyside) do |tag, input|
  input.opts[:label_attr] ||= { class: "block text-sm font-medium text-gray-700 sm:mt-px sm:pt-2" }

  # puts
  # puts "========= labeler (#{ tag.type }) ========="
  # puts input.opts
  # puts tag.class

  Forme::Labeler::Explicit.new.call tag, input
end

Forme.register_transformer(:helper, :sidebyside) do |tag, input|
  [tag, input.tag(:p, { class: "mt-2 text-sm text-gray-500" }, input.opts[:help])]
end

Forme.register_transformer(:error_handler, :sidebyside) do |tag, input|
  input.opts[:error_attr] ||= { class: "mt-2 text-sm text-red-600" }

  inputs = tag.find { |e| e.is_a?(Forme::Tag) && e.type == :input }
  Forme.attr_classes inputs.attr, "border-red-300 text-red-900 placeholder-red-300 focus:outline-none focus:ring-red-500 focus:border-red-500"

  Forme::ErrorHandler.new.call tag, input
end

Forme.register_transformer(:wrapper, :sidebyside) do |tags, input|
  # puts
  # puts "-=-=-=-=-=- Wrapper -=-=-=-=-=-"
  # puts input.opts
  # puts

  a = Array(tags).flatten
  labels, other = a.partition { |e| e.is_a?(Forme::Tag) && e.type.to_s == "label" }

  if labels.length == 1
    ltd = labels
    rtd = other
  else
    ltd = a
  end

  rtd = input.tag :div, { class: "mt-1 sm:mt-0 sm:col-span-2" }, [rtd]
  input.tag :div, { class: "sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5" }, [ltd, rtd]
end

Forme.register_transformer(:inputs_wrapper, :sidebyside_actions) do |form, _opts, &block|
  res = Forme.raw(block.call)

  form.tag :div, { class: "pt-5 sm:border-t sm:border-gray-200" } do
    form.tag :div, { class: "flex justify-end items-baseline" }, [res]
  end
end

Forme.register_transformer(:inputs_wrapper, :sidebyside) do |form, opts, &block|
  # puts
  # puts "********** Inputs Wrapper () ***************"
  # puts opts
  # puts

  res = Forme.raw(block.call)

  form.tag :div, { class: "pb-8 space-y-6 sm:pb-10 sm:space-y-5" } do
    form.tag :fieldset do
      if opts[:legend]
        form.tag :div, class: "pb-6 sm:pb-5 sm:border-b sm:border-gray-200" do
          form.tag :legend, { class: "text-lg leading-6 font-medium text-gray-900" }, opts[:legend]
          form.tag :p, { class: "mt-1 text-sm text-gray-500" }, opts[:legend_sub] if opts[:legend_sub]
        end
      end

      form.tag :div, { class: "mt-6 sm:mt-5 space-y-6 sm:space-y-5" }, res
    end
  end
end

sidebyside = {
  base: :default,
  formatter: :sidebyside,
  labeler: :sidebyside,
  helper: :sidebyside,
  error_handler: :sidebyside,
  wrapper: :sidebyside,
  inputs_wrapper: :sidebyside
}

Forme.register_config :sidebyside, sidebyside
# rubocop:enable Layout/LineLength
