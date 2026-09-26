# Nine Books hadith data

This repo publishes the data for the **Hadith** library in the Quran Kareem app. It holds nine hadith collections, one downloadable SQLite database per book. The app downloads only the books the user picks.

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

Downloading all nine books takes 136.6 MiB (about 650 MiB once uncompressed).

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

## Source and rights

The texts come from the classical hadith collections. The editions, numbering, takhrij, rulings and narrator data follow the editions named in each book's description. See [NOTICE](NOTICE).
