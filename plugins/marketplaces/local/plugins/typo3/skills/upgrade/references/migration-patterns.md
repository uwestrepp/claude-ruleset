# TYPO3 Practical Migration Patterns

Preferred replacement patterns for TYPO3 update/cleanup/migration work, applied when a
clean migration path exists (SHOULD). Relocated from `rules/TYPO3.md` §8 so the content
loads only during upgrade/migration workflows; consult it in `/typo3:upgrade` Phase 5
and during `/typo3:scanner` Pass 2/3 replacements.

- **Extbase request mutation**:
  - avoid legacy `$this->request->setArgument(...)`
  - use immutable `$this->request = $this->request->withArgument(...)`
- **Extbase response mutation**:
  - avoid mutable response APIs (`setHeader()`, `setStatus()`, `setContent()`, direct send/shutdown handling)
  - return PSR-7 responses and use `withHeader()`, `withStatus()` and body streams
  - use ActionController helpers `htmlResponse()` / `jsonResponse()` where possible
- **URL/env access in runtime code**:
  - avoid introducing new usages of `GeneralUtility::getIndpEnv()` for request data
  - prefer the current PSR-7 request (`ServerRequestInterface`) and read values from `$request->getUri()`, `$request->getQueryParams()`, `$request->getParsedBody()`
- **Runtime superglobals in TYPO3 code**:
  - avoid introducing or keeping runtime reads from `$_SERVER`, `$_GET`, `$_POST`, `$_REQUEST`, or `$GLOBALS['TYPO3_REQUEST']` when a request object is available
  - in Extbase controllers, prefer `$this->request->getHeaderLine()`, `$this->request->getQueryParams()`, and argument APIs (`hasArgument()/getArgument()`) as appropriate
  - keep `$GLOBALS` usage only where TYPO3 bootstrap/config APIs require it (for example `TCA`, `TYPO3_CONF_VARS`) and document retained usages in upgrade notes
- **`$GLOBALS['TSFE']` / TypoScriptFrontendController access**:
  - avoid direct `$GLOBALS['TSFE']` reads (discouraged in 12.4; the TSFE is being dismantled toward v13)
  - in cObject/DataProcessor scope use `$cObj->getTypoScriptFrontendController()` (public; may return null → call null-safe with `?->`)
  - page cache tags: 12.4 uses `$tsfe->addCacheTags([...])`; in v13 register them via the `frontend.cache.collector` request attribute (`CacheDataCollector`) instead
- **Legacy service framework**:
  - keeping compatibility wrappers for `AbstractService` / Service API usage is acceptable if required by dependent extensions
  - still migrate deprecated/removed core calls inside those wrappers
- **Service instantiation in upgrade scope**:
  - do not introduce or keep fallback patterns based on `GeneralUtility::makeInstanceService()`
  - prefer constructor or container-based DI for controllers, services, and ViewHelpers where supported
- **`GeneralUtility::makeInstance()` typing in legacy-compatible code**:
  - keep or add inline `@var` type hints directly above assignments from `GeneralUtility::makeInstance(...)`
  - if correcting such annotations, ensure the annotated variable name matches the assigned variable exactly
  - when directly calling a method on a value returned from `GeneralUtility::makeInstance(...)`, prefer `?->` over `->` unless non-nullability is already proven locally and the direct call form is required
- **TypoScript / TSconfig condition array access** (Symfony ExpressionLanguage in `Page.typoscript`, `User.typoscript`, TypoScript condition blocks):
  - avoid direct index access on keys not guaranteed to exist (emits PHP 8.0+ "Undefined array key" warnings from `symfony/expression-language/Node/GetAttrNode.php`); applies to `page`, `tree`, `site`, `siteLanguage`, `applicationContext`, `request`, custom arrays
  - use `traverse(<array>, "<key>")` — returns `null` for missing keys, accepts dotted paths for nested access (`traverse(page, "tx_foo.bar")`), registered in `\TYPO3\CMS\Core\ExpressionLanguage\FunctionsProvider\DefaultFunctionsProvider`, documented safe accessor in TYPO3 12+
  - example: `[page["is_siteroot"] != 1]` → `[traverse(page, "is_siteroot") != 1]`; semantically equivalent for absence-as-not-equal comparisons (no separate behavior confirmation needed)
