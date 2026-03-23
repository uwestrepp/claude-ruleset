---
apply: by model decision
instructions: Load when analyzing TYPO3 deprecations/breaking changes, or during TYPO3 upgrade and migration tasks.
---

# TYPO3 Core: Deprecations & Breaking Changes since TYPO3 v10 LTS (v10.4)

## Scope & sources

- **Start point**: TYPO3 **v10.4 (LTS)** and everything released afterwards (v11, v12, v13, v14).
- **Primary sources (official)**: TYPO3 Core Changelog “combined / changes by type” pages (contain *Breaking Changes* and *Deprecations* lists):
    - v10: https://docs.typo3.org/c/typo3/cms-core/master/en-us/Changelog-10-combined.html
    - v11: https://docs.typo3.org/c/typo3/cms-core/main/en-us/Changelog-11-combined.html
    - v12: https://docs.typo3.org/c/typo3/cms-core/main/en-us/Changelog-12-combined.html
    - v13: https://docs.typo3.org/c/typo3/cms-core/main/en-us/Changelog-13-combined.html
    - v14: https://docs.typo3.org/c/typo3/cms-core/master/en-us/Changelog-14-combined.html
- **Release/version listings (official)**:
    - v10: https://get.typo3.org/list/version/10
    - v11: https://get.typo3.org/list/version/11
    - v12: https://get.typo3.org/list/version/12
    - v13: https://get.typo3.org/list/version/13
    - v14: https://get.typo3.org/list/version/14

> These official changelog pages are the canonical source of truth. This document is a compiled index for agent use.


---

## Versions published since v10 LTS (high-level)

- **TYPO3 v10.4 LTS** (10.4.x line)
- **TYPO3 v11 LTS** (11.0 → 11.5.x line)
- **TYPO3 v12 LTS** (12.0 → 12.4.x line)
- **TYPO3 v13 LTS** (13.0 → 13.4.x line)
- **TYPO3 v14** (14.0.0 released 2025‑11‑25; 14.1.0 released 2026‑01‑20)

**Last compiled:** 2026‑01‑20 (through TYPO3 14.1.0). For newer releases, consult the official changelog pages above.

---

## TYPO3 13.4 migration notes

- Prefer PSR-7 request and response handling in Extbase controllers/traits (see **#92502**).
- For Extbase request arguments, use immutable request APIs (`withArgument`) instead of mutable setters.
- Replace new usages of `GeneralUtility::getIndpEnv()` for request URL/data access with PSR-7 request values (related type hardening in **#101305**).
- Keeping compatibility classes for the legacy Service API can be valid if other in-house extensions still depend on them.

---

# v10 (starting with v10.4 LTS)

## Breaking changes (extract)

- Breaking: **#87511** - Remove `$namespacesViewObjectNamePattern` property
- Breaking: **#87511** - Remove `$viewFormatToObjectNameMap` property
- Breaking: **#87558** - Consolidate extbase caches
- Breaking: **#87567** - Global variable `$TBE_TEMPLATE` removed
- Breaking: **#87583** - Remove obsolete APC Cache Backend implementation
- Breaking: **#87594** - Harden extbase
- Breaking: **#87623** - Replace `config.persistence.classes` TypoScript configuration
- Breaking: **#87627** - Remove property `extensionName` of `AbstractController`
- Breaking: **#87936** - TCA for `sys_history` removed
- Breaking: **#87937** - TCA option `selicon_field_path` removed
- Breaking: **#87957** - Validators are not registered automatically in Extbase anymore
- Breaking: **#87989** - TCA option `setToDefaultOnCopy` removed
- Breaking: **#88129** - Renamed felogin flexform fields
- Breaking: **#88143** - Version-related DB field `t3ver_id` removed
- Breaking: **#88182** - `jsfunc.inline.js` has been dropped
- Breaking: **#88366** - Removed prefix of cache tables
- Breaking: **#88376** - Removed obsolete `pageNotFound_handling` settings
- Breaking: **#88411** - `TBE_EDITOR.typo3form` removed
- Breaking: **#88427** - `jsfunc.evalfield.js` has been removed
- Breaking: **#88458** - Removed Frontend Track User (“ftu”) functionality
- Breaking: **#88496** - Method `getSwitchableControllerActions` has been removed
- Breaking: **#88498** - Global data for TimeTracker statistics removed
- Breaking: **#88500** - RTE image handling functionality dropped
- Breaking: **#88525** - Remove `createDirs` directive of extension installation / `em_conf.php`
- Breaking: **#88527** - Overriding custom values in User Authentication derivatives
- Breaking: **#88540** - Changed request workflow for frontend requests
- Breaking: **#88564** - PageTSconfig setting `TSFE.constants` removed

## Deprecations (extract)

- Deprecation: **#80420** - EmailFinisher single address options
- Deprecation: **#82669** - Streamline backend route path inconsistencies
- Deprecation: **#85895** - Deprecate `File::_getMetaData()`
- Deprecation: **#87200** - EmailFinisher `FORMAT_*` constants
- Deprecation: **#87200** - EmailFinisher “format” option
- Deprecation: **#87305** - Use constructor injection in DataMapper
- Deprecation: **#87332** - Avoid runtime reflection calls in ObjectAccess
- Deprecation: **#87550** - Use controller classes when registering plugins/modules
- Deprecation: **#87613** - Deprecate `\TYPO3\CMS\Extbase\Utility\TypeHandlingUtility::hex2bin`
- Deprecation: **#87882** - File-related controllers moved to EXT:filelist
- Deprecation: **#87894** - `GeneralUtility::idnaEncode`
- Deprecation: **#88366** - Default caching framework cache names changed
- Deprecation: **#88406** - `setCacheHash/noCacheHash` options in ViewHelpers and UriBuilder
- Deprecation: **#90390** - `BrokenLinkRepository::getNumberOfBrokenLinks()` in linkvalidator
- Deprecation: **#90421** - DocumentTemplate
- Deprecation: **#90522** - TSFE properties regarding images
- Deprecation: **#88740** - ext:felogin pibase plugin related hooks
- Deprecation: **#90147** - Unified File Name Validator
- Deprecation: **#90377** - Param types `$ref` of method `callUserFunction`
- Deprecation: **#90625** - Extbase SignalSlot Dispatcher
- Deprecation: **#90686** - Model FileMount
- Deprecation: **#90692** - FileCollection models
- Deprecation: **#90800** - `GeneralUtility::isRunningOnCgiServerApi`
- Deprecation: **#90803** - `ObjectManager::get` in Extbase context
- Deprecation: **#90856** - Widget AutoComplete ViewHelper
- Deprecation: **#90861** - Image-related methods within ContentObjectRenderer
- Deprecation: **#90937** - Various hooks in ContentObjectRenderer
- Deprecation: **#90956** - Alternative fetch methods and reports for `GeneralUtility::getUrl()`
- Deprecation: **#90964** - LanguageService functionality and internal properties
- Deprecation: **#91001** - Various methods within GeneralUtility
- Deprecation: **#91012** - Various hooks related to TypoScriptFrontendController
- Deprecation: **#91030** - Runtime-Activated Packages

---

# v11

## Breaking changes (extract)

- Breaking: **#91473** - Deprecated functionality removed
- Breaking: **#91562** - cObject TEMPLATE removed
- Breaking: **#91563** - PHP-based JS + CSS inclusions for Frontend removed
- Breaking: **#91578** - IRRE related JavaScript has been removed
- Breaking: **#91606** - Date/time operations in FormEngine removed
- Breaking: **#91740** - Deprecated icon identifier removed
- Breaking: **#91782** - lockToDomain feature removed (FE/BE users/groups)
- Breaking: **#91906** - Store TransOrigDiffSourceField as json string
- Breaking: **#91909** - sys_collection DB tables moved into external extension
- Breaking: **#91974** - Configuration option IPmaskMountGroups removed
- Breaking: **#92060** - Dropped class `TYPO3\CMS\Backend\View\PageTreeView`
- Breaking: **#92118** - TCA ctrl thumbnail setting dropped
- Breaking: **#92128** - DatabaseRecordList: drop hook to modify searchFields
- Breaking: **#92132** - Last remains of globals SOBE removed
- Breaking: **#92206** - Remove workspace swapping of elements
- Breaking: **#92238** - Service injection in Extbase validators
- Breaking: **#92289** - Decouple logic of ResourceFactory into StorageRepository
- Breaking: **#92352** - New default position for redirect middleware
- Breaking: **#92457** - Extension Repository DB table removed
- Breaking: **#92497** - Workspaces: Move Placeholders removed
- Breaking: **#92499** - AdminPanel does not preview hidden FE user groups
- Breaking: **#92502** - Make Extbase handle PSR-7 responses only
- Breaking: **#92513** - Signature change `ControllerInterface::processRequest`
- Breaking: **#92529** - All Fluid widget functionality removed
- Breaking: **#92532** - Support for extension-in-extension installation in EM removed
- Breaking: **#92558** - DB field `be_users.createdByAction` removed
- Breaking: **#92559** - Removed per-user IP locking for backend users
- Breaking: **#92560** - Backend editors can always delete pages recursive
- Breaking: **#92582** - Resizable text area user setting dropped
- Breaking: **#92590** - Removed support for extension upload of t3x files

## Deprecations (extract)

- Deprecation: **#89938** - Language mode in Typo3QuerySettings
- Deprecation: **#91606** - Global Datetime Picker initialization
- Deprecation: **#91911** - optionEl of type jQuery in `FormEngine.setSelectOptionFromExternalSource`
- Deprecation: **#92062** - Migrate RecordListController hooks to PSR-14 event
- Deprecation: **#92080** - QueryGenerator and QueryView
- Deprecation: **#92132** - Shortcut PHP API
- Deprecation: **#92132** - ViewHelper `f:be.buttons.shortcut`
- Deprecation: **#92386** - Extbase property injection
- Deprecation: **#92435** - StandaloneView for EmailFinisher
- Deprecation: **#92551** - GeneralUtility methods related to pages.l18n_cfg behavior

(Additional deprecations excerpted further down the official list)

- Deprecation: **#94227** - f:base ViewHelper
- Deprecation: **#94228** - Extbase request `getRequestUri()`
- Deprecation: **#94231** - Extbase InvalidRequestMethodException
- Deprecation: **#94252** - GeneralUtility::compileSelectedGetVarsFromArray
- Deprecation: **#94272** - Application->run callback
- Deprecation: **#94309** - GeneralUtility::stdAuthCode
- Deprecation: **#94311** - GeneralUtility::rmFromList
- Deprecation: **#94313** - AbstractService class
- Deprecation: **#94316** - HTTP header manipulating methods from HttpUtility
- Deprecation: **#94317** - ext:form Finisher implementations
- Deprecation: **#94351** - ext:extbase StopActionException
- Deprecation: **#94367** - Extbase ReferringRequest
- Deprecation: **#94377** - Extbase ObjectManager->getEmptyObject
- Deprecation: **#94394** - Extbase Request setDispatched()/isDispatched()
- Deprecation: **#94414** - LanguageService container entry
- Deprecation: **#85613** - Category Registry
- Deprecation: **#94619** - Extbase ObjectManager
- Deprecation: **#94654** - Generic Extbase domain classes
- Deprecation: **#94664** - Pdo cache backend
- Deprecation: **#94665** - Wincache cache backend
- Deprecation: **#94684** - GeneralUtility::shortMD5()
- Deprecation: **#94687** - Deprecate SoftReferenceIndex
- Deprecation: **#94741** - Register SoftReference parsers via DI
- Deprecation: **#94762** - Deprecate JavaScript top.fsMod state
- Deprecation: **#94902** - Deprecate lowerCamelCase options of EXT:impexp commands
- Deprecation: **#94953** - Edit panel related frontend functionality
- Deprecation: **#94956** - Public $cObj
- Deprecation: **#94957** - TSFE->cObjectDepthCounter
- Deprecation: **#94958** - ContentObjectRenderer properties
- Deprecation: **#94959** - ContentObjectRenderer constructor in StandaloneView
- Deprecation: **#94979** - Using CacheManager/DB connections during bootstrap
- Deprecation: **#94991** - Extbase AbstractView
- Deprecation: **#94996** - In Composer mode, extensions should be installed with Composer
- Deprecation: **#95003** - Extbase ViewInterface canRender()

---

# v12

## Breaking changes (extract)

From the official “12.x changes by type” page (excerpt of the breaking list):

- Breaking: **#97174** - Removed hook for modifying info module footer content
- Breaking: **#97187** - Removed hook for modifying link explanation
- Breaking: **#97188** - Register element browsers via service configuration
- Breaking: **#97201** - Removed hook for new content element wizard
- Breaking: **#97210** - Types added to method signatures or class properties
- Breaking: **#97214** - Use UploadedFile objects instead of $_FILES
- Breaking: **#97230** - Removed hook for modifying image manipulation preview URL
- Breaking: **#97231** - Removed hook for manipulating inline element controls
- Breaking: **#97243** - Remove global jQuery access via window.$
- Breaking: **#97265** - Simplified access mode system
- Breaking: **#97305** - Introduce CSRF-like login token
- Breaking: **#97312** - Remove context sensitive help
- Breaking: **#97320** - Register Report and Status via Service Configuration
- Breaking: **#97358** - Removed eval=int from TCA type "datetime"
- Breaking: **#97449** - Removed hook for modifying flex form parsing
- Breaking: **#97450** - Removed hook for modifying version differences
- Breaking: **#97451** - Removed BackendController page hooks
- Breaking: **#97452** - Removed EditFileController hooks
- Breaking: **#97454** - Removed Link Browser hooks
- Breaking: **#97530** - Indexed Search option searchSkipExtendToSubpagesChecking removed
- Breaking: **#97550** - TypoScript option config.disableCharsetHeader removed
- Breaking: **#97605** - Remove field resizeTextareas_MaxHeight from user settings
- Breaking: **#97701** - TSconfig option disableNewContentElementWizard removed
- Breaking: **#97729** - Respect attribute approved in XLF files
- Breaking: **#97737** - Page-related hooks in TSFE removed
- Breaking: **#97752** - MailerAdapterInterface removed
- Breaking: **#97787** - AbstractMessage->getSeverity() returns ContextualFeedbackSeverity
- Breaking: **#97797** - GFX setting processor_path_lzw removed
- Breaking: **#97816** - New TypoScript parser in Frontend
- Breaking: **#97816** - TypoScript syntax changes
- Breaking: **#97862** - Hooks related to generating page content removed
- Breaking: **#97926** - Extbase QuerySettings methods removed
- Breaking: **#97927** - Removed TypoScript option config.doctypeSwitch

## Deprecations (extract)

- Deprecation: **#99084** - Make trigger of context menu configurable
- Deprecation: **#99098** - Static usage of FormProtectionFactory
- Deprecation: **#99150** - Updated chart library in EXT:dashboard
- Deprecation: **#99170** - config.baseURL and <base> tag functionality
- Deprecation: **#99201** - UserSessionManager->createFromGlobalCookieOrAnonymous
- Deprecation: **#97923** - Deprecate UserFileMountService
- Deprecation: **#99120** - Deprecate old TypoScriptParser
- Deprecation: **#99416** - Various doctype related properties and methods
- Deprecation: **#99454** - Restore visibility for soft hyphens and non-breaking spaces
- Deprecation: **#99519** - Deprecated BackendUtility::getFuncMenu()
- Deprecation: **#99523** - Deprecate type="none" pass_content
- Deprecation: **#99531** - Backwards-compatible language key mapping
- Deprecation: **#99558** - Deprecate PageRepository->getExtURL()
- Deprecation: **#99564** - Deprecated BackendUtility::getDropdownMenu()
- Deprecation: **#99579** - BackendUtility::getFuncCheck()
- Deprecation: **#99586** - Registration of upgrade wizards via $GLOBALS
- Deprecation: **#99588** - Public Properties in PageRepository
- Deprecation: **#99592** - Deprecated "flushByTag" hook
- Deprecation: **#99615** - GeneralUtility::_GPmerged()
- Deprecation: **#99633** - GeneralUtility::_POST()
- Deprecation: **#99638** - Environment::getBackendPath()
- Deprecation: **#99650** - Global Request object usage in Extbase UriBuilder
- Deprecation: **#99685** - PageRenderer::removeLineBreaksFromTemplate
- Deprecation: **#99717** - Deprecated "modifyBlindedConfigurationOptions" hook
- Deprecation: **#99811** - Deprecate JavaScript bootstrap tooltip
- Deprecation: **#83608** - Backend user's getDefaultUploadFolder hook
- Deprecation: **#97390** - TypoScript validators for password reset in ext:felogin
- Deprecation: **#99739** - Indexed array keys for TCA items
- Deprecation: **#99810** - "versionNumberInFilename" option now boolean
- Deprecation: **#99882** - Site language "typo3Language" setting
- Deprecation: **#99900** - $limit parameter of GeneralUtility::intExplode()
- Deprecation: **#99905** - Site language "iso-639-1" setting
- Deprecation: **#99908** - Site language "hreflang" setting
- Deprecation: **#99916** - Site language "direction" setting
- Deprecation: **#99932** - PageRenderer::removeLineBreaksFromTemplate
- Deprecation: **#100014** - getParameterFromUrl() in @typo3/backend/utility
- Deprecation: **#100033** - TBE_STYLES stylesheet and stylesheet2
- Deprecation: **#100047** - Deprecated ConditionMatcher classes

---

# v13

## Breaking changes (extract)

- Breaking: **#97330** - FormEngine element classes must create label or legend
- Breaking: **#97664** - FormPersistenceManagerInterface modified
- Breaking: **#99323** - Removed hook for modifying records after fetching content
- Breaking: **#99807** - Relocated ModifyUrlForCanonicalTagEvent
- Breaking: **#99898** - Continuous array keys from GeneralUtility::intExplode
- Breaking: **#99937** - Use BIGINT DB column type for datetime TCA
- Breaking: **#100224** - MfaViewType migrated to backed enum
- Breaking: **#100229** - Convert JSConfirmation to a BitSet
- Breaking: **#100963** - Deprecated functionality removed
- Breaking: **#100966** - Remove jquery-ui
- Breaking: **#101129** - Convert Action to native backed enum
- Breaking: **#101131** - Convert LoginType to native backed enum
- Breaking: **#101133** - IconFactory->getIcon() signature change
- Breaking: **#101133** - Icon->state changed type
- Breaking: **#101137** - Page doktype “Recycler” removed
- Breaking: **#101143** - Strict typing in LinktypeInterface
- Breaking: **#101149** - Mark PageTsBackendLayoutDataProvider as final
- Breaking: **#101175** - Convert VersionState to native backed enum
- Breaking: **#101186** - Strict typing in UnableToLinkException
- Breaking: **#101192** - Remove fallback for CKEditor removePlugins
- Breaking: **#101266** - Remove RequireJS
- Breaking: **#101281** - Type declarations in ResourceInterface
- Breaking: **#101291** - Introduce capabilities bit set
- Breaking: **#101294** - Type declarations in FileInterface
- Breaking: **#101305** - Type declarations for some methods in GeneralUtility
- Breaking: **#101309** - Type declarations in DriverInterface
- Breaking: **#101311** - GeneralUtility::sanitizeLocalUrl parameter required
- Breaking: **#101327** - Harden FileInterface::getSize()
- Breaking: **#101398** - Remove leftover $fetchAllFields in RelationHandler
- Breaking: **#101469** - Type declarations in FolderInterface
- Breaking: **#101471** - Type declarations in AbstractDriver
- Breaking: **#101519** - Remove immediate flag in DebounceEvent
- Breaking: **#101603** - Removed hook for overriding icon overlay identifier

## Deprecations (extract)

- Deprecation: **#87889** - TYPO3 backend entry point script deprecated
- Deprecation: **#101133** - IconState class
- Deprecation: **#101151** - DuplicationBehavior class
- Deprecation: **#101163** - Abstract class Enumeration
- Deprecation: **#101174** - InformationStatus class
- Deprecation: **#101175** - Methods in VersionState
- Deprecation: **#101475** - Icon::SIZE_* string constants
- Deprecation: **#101554** - Obsolete TCA MM_hasUidField
- Deprecation: **#101793** - DataHandler checkStoredRecords properties
- Deprecation: **#101799** - ExtensionManagementUtility::addPageTSConfig()
- Deprecation: **#101807** - ExtensionManagementUtility::addUserTSConfig()
- Deprecation: **#101912** - Passing jQuery objects to FormEngine validation
- Deprecation: **#102032** - AbstractFile::FILETYPE_* constants
- Deprecation: **#102440** - EXT:t3editor merged into EXT:backend
- Deprecation: **#102581** - Unused interface for ContentObjectRenderer hook
- Deprecation: **#102586** - Deprecate simple string connection driver middleware registration
- Deprecation: **#102614** - Unused interface for GetData Hook
- Deprecation: **#102624** - Unused interface for getImageSourceCollection Hook
- Deprecation: **#102631** - Deprecated Controller attribute for auto configuring backend controllers
- Deprecation: **#102745** - Unused interface for stdWrap hook
- Deprecation: **#102755** - Unused interface for getImageResource hook
- Deprecation: **#102763** - Extbase HashService
- Deprecation: **#102793** - PageRepository->enableFields
- Deprecation: **#102806** - Interfaces for PageRepository hooks
- Deprecation: **#102895** - ExtensionManagementUtility::getExtensionIcon
- Deprecation: **#102908** - Indexed Search content parsers returning arrays
- Deprecation: **#105171** - INCLUDE_TYPOSCRIPT TypoScript syntax
- Deprecation: **#105213** - TCA sub types
- Deprecation: **#105230** - TSFE and $GLOBALS['TSFE']
- Deprecation: **#105252** - DataProviderContext getters and setters
- Deprecation: **#105279** - Replace TYPO3 EnumType with Doctrine DBAL EnumType
- Deprecation: **#105297** - tableoptions and collate connection configuration

---

# v14

## Breaking changes (extract)

- Breaking: **#101292** - Strong-typed PropertyMappingConfigurationInterface
- Breaking: **#101392** - getIdentifier() and setIdentifier() from AbstractFile removed
- Breaking: **#103141** - Use doctrine GUID type for TCA type=uuid
- Breaking: **#103910** - Change logout handling in EXT:felogin
- Breaking: **#103913** - Do not perform redirect in EXT:felogin logoutAction
- Breaking: **#104422** - Move GET parameters in sitemap into namespace
- Breaking: **#105377** - Deprecated functionality removed
- Breaking: **#105549** - Improved ISO8601 Date Handling in TYPO3 DataHandler
- Breaking: **#105686** - Avoid obsolete $charset in sanitizeFileName()
- Breaking: **#105695** - Simplified CharsetConverter
- Breaking: **#105728** - Extbase backend modules not in page context rely on global TypoScript only
- Breaking: **#105733** - FileNameValidator no longer accepts custom regex in __construct()
- Breaking: **#105809** - AfterMailerInitializationEvent removed
- Breaking: **#105855** - Remove file backwards compatibility for alt and link field
- Breaking: **#105863** - Remove exposeNonexistentUserInForgotPasswordDialog setting in EXT:felogin
- Breaking: **#105920** - Folder->getSubFolder() throws FolderDoesNotExistException
- Breaking: **#106041** - TypoScript Extbase toggle config.tx_extbase.persistence.updateReferenceIndex removed
- Breaking: **#106056** - Add setRequest/getRequest to Extbase ValidatorInterface
- Breaking: **#106118** - Property DataHandler->storeLogMessages removed
- Breaking: **#106307** - Use stronger cryptographic algorithm for HMAC
- Breaking: **#106405** - TypolinkBuilder signature changes
- Breaking: **#106412** - TCA interface settings for list view removed
- Breaking: **#106427** - File Abstraction Layer related changes
- Breaking: **#106503** - Removal of fields from sys_file_metadata
- Breaking: **#106596** - Remove legacy form templates
- Breaking: **#106863** - TCA control option is_static removed
- Breaking: **#106869** - Remove static function parameter in AuthenticationService
- Breaking: **#106949** - Duplicate doktype restriction configuration removed
- Breaking: **#106964** - Enable "Light/Dark Mode" context awareness for CKEditor RTE by default

## Deprecations (extract)

- Deprecation: **#93981** - GraphicalFunctions->gif_or_jpg
- Deprecation: **#97559** - Deprecate passing an array of configuration values to Extbase attributes
- Deprecation: **#97857** - Deprecate __inheritances operator in form configuration
- Deprecation: **#98453** - Scheduler task registration via SC_OPTIONS
- Deprecation: **#106393** - Various methods in BackendUtility
- Deprecation: **#106405** - AbstractTypolinkBuilder->build
- Deprecation: **#106527** - markFieldAsChanged() moved to FormEngine main module
- Deprecation: **#106618** - GeneralUtility::resolveBackPath
- Deprecation: **#106821** - Workspace-aware inline child tables are enforced
- Deprecation: **#106947** - Move upgrade wizard related interfaces and attribute to EXT:core
- Deprecation: **#106969** - Deprecate User TSConfig auth.BE.redirectToURL
- Deprecation: **#107047** - ExtensionManagementUtility::addPiFlexFormValue()
- Deprecation: **#107057** - Deprecate auto-render assets sections
- Deprecation: **#107225** - Boolean sort direction in FileList->start()
- Deprecation: **#107229** - Deprecate Annotation namespace of Extbase attributes
- Deprecation: **#107287** - FileCollectionRegistry->addTypeToTCA() method
- Deprecation: **#107413** - PathUtility getRelativePath(to) methods
- Deprecation: **#107436** - Localization Parsers
- Deprecation: **#107537** - GeneralUtility::createVersionNumberedFilename
- Deprecation: **#107537** - FilePathSanitizer service
- Deprecation: **#107537** - PathUtility::getPublicResourceWebPath
- Deprecation: **#107550** - Table Garbage Collection Task config via $GLOBALS
- Deprecation: **#107562** - IP Anonymization Task config via $GLOBALS
- Deprecation: **#107648** - InfoboxViewHelper STATE_* constants
- Deprecation: **#107725** - Deprecate usage of array in password for authentication in Redis cache backend
- Deprecation: **#107813** - Deprecate MetaInformation API in DocHeader
- Deprecation: **#107823** - ButtonBar/Menu/MenuRegistry make* methods deprecated
- Deprecation: **#107938** - Deprecate unused XLIFF files
- Deprecation: **#107963** - sys_redirect default type name changed to "default"
- Deprecation: **#108008** - Manual shortcut button creation
- Deprecation: **#108148** - Fluid LenientArgumentProcessor
- Deprecation: **#108227** - Usage of #[IgnoreValidation]/#[Validate] at method level
- Deprecation: **#108086** - Raise deprecation error on using deprecated labels
- Deprecation: **#108524** - Fluid namespaces in TYPO3_CONF_VARS
- Deprecation: **#108667** - Deprecate CommandNameAlreadyInUseException
- Deprecation: **#107068** - Rename fieldExplanationText to description
- Deprecation: **#107208** - <f:debug.render> ViewHelper
- Deprecation: **#107802** - Deprecate usage of array in password for authentication in Redis session backend
- Deprecation: **#108557** - TCA option allowedRecordTypes for Page Types
