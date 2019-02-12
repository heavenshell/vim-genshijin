## vim-genshijin

Genshijin is port of [Qiita's entry](https://qiita.com/Harusugi/items/f499e8707b36d0f570c4).

## Usage

### Settings

Get `client_id` and `client_secret` from [COTOHA API Portal](https://api.ce-cotoha.com/contents/index.html).

Add `cotoha_client_id` and `cotoha_client_secret` into your `.vimrc`.

```viml
let g:cotoha_client_id = 'YOUR_CLIENT_ID'
let g:cotoha_client_secret = 'YOUR_CLIENT_SECRET'
```

### Visual select

Write Japanese and visual select text than type `:'<,'>Genshijin` will replace to genjinized text.

### Commandline

`:Genshijin PUT JAPANESE HERE`

## License

New BSD License
