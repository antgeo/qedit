# TODO — Pre-release fixes

## Code quality

### Simplify `build_tree` hidden files logic (`app/controllers/qedit/editor_controller.rb:53-55`)
The two chained `.reject` calls are convoluted. Simplify to one pass:

```ruby
entries = Dir.entries(path).sort.reject { |e| e == "." || e == ".." || e.start_with?(".") }
```

Note: this also hides `.git` — if that should remain visible, handle it explicitly in the exclusion list rather than the dotfile rule.

---

## Future / post-release

- **Test suite** — no tests exist. At minimum: path traversal attempts, file read/write round-trips, lint endpoint with a stub rubocop response, and the development-only guard.
- **Lint error visibility** — the frontend silently swallows lint errors. If RuboCop is misconfigured the user has no indication linting is non-functional.
- **Binary file detection** — `show` action has no guard against binary files. Opening an image or compiled asset will send garbage to Monaco. Check file encoding or extension before reading.
