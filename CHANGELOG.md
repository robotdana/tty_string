# v2.0.1
- Fix warning

# v2.0.0
- TTYString is now a module not a class.
- Address the issue where preserved styles and unknown codes would cause the cursor to be misaligned when moving, and potentially overwriting styles unexpectedly:
  - `clear_style: false` is now `style: TTYString::RENDER`, which modifies styles to display as they would rather than just passing them through them unprocessed
  - `clear_style: true` is now `style: TTYString::DROP` (and still the default)
  - Unknown codes are now dropped by default
  - it's now possible to set `unknown: TTYString::RAISE` to raise on unrecognized CSI codes (`unknown: TTYString::DROP` is the default)
- drop more codes that are known to do nothing for the display of text `\e[?5l`,`\e[?5h`,`\e[?25l`,`\e[?25h`,`\e[?1004l`,`\e[?1004h`,`\e[?1049l`,`\e[?1049h`

# v1.1.1
- i forgot how arity works

# v1.1.0
- suppress bracketed paste mode codes

# v1.0.1
- test push to rubygems, no functional changes

# v1.0.0
- added TTYString.parse as a shortcut for .new#to_s
- added TTYString.to_proc for lols
- added jruby to travis matrix, fortunately it just works™

# v0.2.1
- fixed a bug with ignoring \a

# v0.2.0
- Stricter rendering because it turns out terminals are randomly permissive
- removed support for ruby 2.3
- added \e[S and \e[T handling

# v0.1.0
- Initial Release
