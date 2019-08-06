# NAME

Text::BibTeX::Entry::Plus - helper for exporting bibliography in an arbitrary format from BibTeX files

# SYNOPSIS

```perl
use Text::BibTeX::Entry::Plus;

$bibfile = Text::BibTeX::File->new('PATH_TO_BIBFILE');
$entry = Text::BibTeX::Entry::Plus->new($bibfile);

$entry->export_as_string();
```

# DESCRIPTION

Text::BibTeX::Entry::Plus provides helper functions for exporting
bibliography in an arbitrary format from BibTeX files, which is an
extension of a Perl module, Text::BibTeX::Entry.

Using Text::BibTeX::Entry::Plus, you can export your bibliography in
arbitrary format (e.g., Text, HTML, and CSV) if you are familiar with
Perl language.

# SEE ALSO

Text::BibTeX(3pm)

# LICENSE

Copyright (C) Ryo Nakamura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Ryo Nakamura <nakamura[atmark]zebulun.net>
