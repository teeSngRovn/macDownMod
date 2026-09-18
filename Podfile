platform :osx, "10.8"

source 'https://github.com/MacDownApp/cocoapods-specs.git'  # Patched libraries.
source 'https://cdn.cocoapods.org/'

project 'MacDown.xcodeproj'

inhibit_all_warnings!

target "MacDown" do
  pod 'handlebars-objc', '~> 1.4'
  pod 'hoedown', '~> 3.0.7', :inhibit_warnings => false
  pod 'JJPluralForm', '~> 2.1'
  pod 'LibYAML', '~> 0.1'
  pod 'M13OrderedDictionary', '~> 1.1'
  pod 'MASPreferences', '~> 1.3'
  pod 'Sparkle', '~> 1.18', :inhibit_warnings => false

  # Locked on 0.4.x until we drop 10.8.
  pod 'PAPreferences', '~> 0.4'
end

target "MacDownTests" do
  pod 'PAPreferences', '~> 0.4'
end

target "macdown-cmd" do
  pod 'GBCli', '~> 1.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '12.0'
    end
  end

  # Hoedown 3.0.7 only recognizes doubled backslashes around TeX math.
  # Accept the standard \[...\] and \(...\) delimiters as well.
  document_path = File.join(installer.sandbox.root, 'hoedown', 'src', 'document.c')
  source = File.binread(document_path)
  original = <<'C'
		if (data[1] == '\\' && (doc->ext_flags & HOEDOWN_EXT_MATH) &&
C
  replacement = <<'C'
		if ((doc->ext_flags & HOEDOWN_EXT_MATH) &&
			(data[1] == '(' || data[1] == '[')) {
			const char *end = (data[1] == '[') ? "\\]" : "\\)";
			w = parse_math(ob, doc, data, offset, size, end, 2, data[1] == '[');
			if (w) return w;
		}

		if (data[1] == '\\' && (doc->ext_flags & HOEDOWN_EXT_MATH) &&
C
  if source.include?(original) && !source.include?(replacement)
    source = source.sub(original) { replacement }
  elsif !source.include?(replacement)
    raise 'Could not patch Hoedown math delimiters; inspect document.c'
  end

  # The old display-mode guess applies to $$, but would misclassify \(...\).
  old_display_check = 'if (delimsz == 2 && !(doc->ext_flags & HOEDOWN_EXT_MATH_EXPLICIT))'
  new_display_check = "if (delimsz == 2 && end[0] == '$' && !(doc->ext_flags & HOEDOWN_EXT_MATH_EXPLICIT))"
  if source.include?(old_display_check)
    source = source.sub(old_display_check, new_display_check)
  elsif !source.include?(new_display_check)
    raise 'Could not patch Hoedown math display mode; inspect document.c'
  end

  if source != File.binread(document_path)
    File.chmod(0644, document_path)
    File.binwrite(document_path, source)
  end
end
