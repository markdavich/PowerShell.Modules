# 🧱 PowerShell Module Architecture (Way 1 - Behavior-Oriented)

This structure groups modules by **function or role**, such as `Parser` or `Attribute`, instead of by domain.

Each module folder contains:

- A `.psm1` file with a class

- A `.psd1` manifest

- Autoloadable if the folder is added to `$env:PSModulePath`

---

## `User.Abstracts.Parser`

- Class: `ParserBase`
- Using: `using module User.Abstracts.Parser`

## `User.Abstracts.Parser.Attribute`

- Class: `AttributeParserBase`
- Using: `using module User.Abstracts.Parser.Attribute`

## `User.Abstracts.Attribute`

- Class: `AttributeBase`
- Using: `using module User.Abstracts.Attribute`

## `User.Implementations.Parser.Attribute.Markup`

- Class: `MarkupAttribute`
- Using: `using module User.Implementations.Parser.Attribute.Markup`

## `User.Implementations.Parser.Markup`

- Class: `MarkupParser`
- Using: `using module User.Implementations.Parser.Markup`

## `User.Implementations.Parser.Aspx.PageDirective`

- Class: `PageDirectiveParser`
- Using: `using module User.Implementations.Parser.Aspx.PageDirective`
