# Nine Books hadith data

This repo publishes the data for the **Hadith** library in the Quran Kareem app. It holds the nine books plus eight more collections, one downloadable SQLite database per book. The app downloads only the books the user picks.

The databases are **not committed**. They are attached to each [GitHub Release](../../releases) as `book_<BookID>.db.gz`, next to a `manifest.json`. The app reads the manifest from the latest release:

```
https://github.com/bilalelsayed97/hadith-nine-books-data/releases/latest/download/manifest.json
```

## Books

| Order | BookID | Book | Download |
|---:|---:|---|---:|
| 1 | 7 | صحيح البخاري | 21.5 MiB |
| 2 | 5 | صحيح مسلم | 12.6 MiB |
| 3 | 6 | سنن أبي داود | 12.5 MiB |
| 4 | 4 | سنن الترمذي | 11.8 MiB |
| 5 | 1 | سنن النسائي | 12.5 MiB |
| 6 | 2 | سنن ابن ماجه | 9.4 MiB |
| 7 | 9 | موطأ مالك | 5.2 MiB |
| 8 | 8 | سنن الدارمي | 6.1 MiB |
| 9 | 11 | مسند أحمد | 45.0 MiB |
| 10 | 101 | رياض الصالحين | 961 KiB |
| 11 | 102 | بلوغ المرام | 873 KiB |
| 12 | 103 | الأربعون النووية | 40 KiB |
| 13 | 104 | الأربعون القدسية | 41 KiB |
| 14 | 105 | أربعون شاه ولي الله الدهلوي | 12 KiB |
| 15 | 106 | مشكاة المصابيح | 2.2 MiB |
| 16 | 107 | الأدب المفرد | 744 KiB |
| 17 | 108 | الشمائل المحمدية | 224 KiB |

Downloading all 17 books takes 141.6 MiB. All 17 are in release v2026.10.1. Books 101–108 were converted from sunnah.com-style databases into the same schema, and also carry an English `Translation`, a `TakhrijText` and a lower-cased `TranslationSearch` column.

## Manifest

```json
{
  "schemaVersion": 1,
  "corpusVersion": "2026.09.1",
  "books": [{
    "bookId": 7, "sort": 1,
    "url": "https://github.com/.../releases/download/v2026.09.1/book_7.db.gz",
    "gzSize": 22548589, "gzSha256": "…",
    "dbSize": 99844096, "dbSha256": "…",
    "hadithCount": 7103
  }]
}
```

- `gzSha256` is checked after the download. `dbSha256` is checked after un-gzipping and before the app opens the file.
- `corpusVersion` changes whenever any book changes. An installed book whose version is older shows "Update available" in the app.
- `schemaVersion` changes only when the manifest or table layout breaks older app builds.

## What is in each book database

Each database is a per-book split of the corpus, and `Hadeths.Text` is already plaintext. The release build makes these changes:

- **Indexes added** for index browsing, reading, takhrij, rulings, topics and narrators.
- **`Rwah.SearchName` added.** It is the normalized form of the narrator's name variants.
- **Shared tables removed.** `SubjectsTree`, `SubjectsTreeLinks` and `Notes` are shared across books, so the app bundles them in its own `hadith_meta.sqlite` instead.

Tables: `Books`, `Hadeths`, `HadethsSubjects`, `Takhrig`, `Ahkam`, `Rwah`, `RwahAqwal`, `RwahSources`, `ghareeb_words`.

## Publishing a new corpus version

1. In the app repo, build the release into this repo's `dist/`:
   ```bash
   python3 tool/hadith_books/build_release.py \
     --source ~/Desktop/"Nine Books App Export" \
     --corpus-version 2026.09.1 \
     --base-url https://github.com/bilalelsayed97/hadith-nine-books-data/releases/download/v2026.09.1 \
     --out ../hadith-nine-books-data/dist
   ```
2. Here, run `scripts/publish.sh 2026.09.1`. It checks every asset against the manifest, commits `manifest.json`, pushes, and creates the release.

A release asset can be up to 2 GiB. The largest file here is 45 MiB.
