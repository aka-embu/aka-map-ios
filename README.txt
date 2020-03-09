Akamai Mobile App Performance (MAP) SDK for iOS
===============================================


MOBILE APP PERFORMANCE
--------------------
Akamai’s Mobile Application Performance (MAP) SDK enables app owners and developers to
understand the causes of mobile application latency and to optimize and accelerate their
app’s API and image requests over Akamai Intelligent Platform.


More information can be found at: http://developer.akamai.com/


VERSION
--------------------
21.12


INSTALLATION
--------------------
Please find detailed installation instructions in Mobile Accelerator SDK iOS Integration
Guide.

USAGE
--------------------
* Important API usages can be found in the integration guide.
* Get up and running with the MAP SDK with the apps in examples folders



LICENSE
--------------------
Use of this SDK is governed by the Mobile Application Performance (MAP), Predictive
Content Delivery (PCD) and WatchNow SDK License Agreement found at
https://www.akamai.com/product/licenses .


RELEASE NOTES
--------------------

21.12 - 2020-02-27

- Support segment-level controls for network type (e.g., download this manifest's
  contents over wifi only).
- Support segment-level controls for alternate download sources.



21.11 - 2020-01-16

- Support downloading segments in priority order. 
  Priorities can be set at the MAP portal ingestion page.

- Open a fallback connection when SR4C can't connect to a hostname.
  Prevent SR4C on that hostname until the server configuration changes.

- API key and segment names from Info.plist have their start and end whitespace trimmed.



20.41 - 2019-12-19

- Provide direct cache access via API, with optional callbacks for cache changes.
- Prevent If-Modified-Since checks on cached files from being cached by the OS, 
  ensuring requests for updated content are fulfilled.



20.33 - 2019-11-06

- Replace internal use of UIWebView with WKWebView for getting default User-Agent.



20.32 - 2019-09-26

- Split framework into AkaCommon and AkaMap to combine
  support for MAP and mPulse SDKs.
- Reduce overall SDK size.



20.13 - 2019-04-18

- Internal optimizations.

KNOWN ISSUES
    No known issues.



20.12 - 2019-02-21

- Changing user segments causes an immediate sync with the server to get the 
  latest contents.  Previous behavior was to wait until next sync (e.g., app 
  coming to foreground if several minutes had passed since last sync).

- Ignore OPTIONS requests by default.  Ignore other HTTP/S request methods
  as follows, or set to nil to have MAP SDK intercept all requests:

  akaService.config.ignoredHTTPMethods = @[@"post",@"options"];

- Allow re-registration in case app is registered to the wrong license.
  If the app launches with a new license in the plist, the old one will 
  unregister followed by registering the new license.

  Similarly, if the (deprecated) register API is used, the previous license
  will deregister followed by registering the new license.  Plist is the
  preferred method.

  Note: This is intended to correct license errors, not to switch features
  at runtime. Features should be changed via the Web portal.

- Cleanup Swift sample app.

KNOWN ISSUES
    No known issues.



20.11 - 2019-01-18

- Comment cleanup.

KNOWN ISSUES
    No known issues.



19.43 - 2018-12-14

- Adaptive preposition/prefetch downloads based on network interface.

KNOWN ISSUES
    No known issues.



19.42 - 2018-11-15

- Added autoFollowRedirects property for apps choosing to not follow redirects.

KNOWN ISSUES
    No known issues.



19.41 - 2018-10-11

- Added reporting of debug console prints left on in production apps.

KNOWN ISSUES
    No known issues.



19.33 - 2018-09-12

- Improved cache-control handling for max-stale and must-revalidate.

KNOWN ISSUES
    No known issues.



19.32 - 2018-08-16

- Capture redirects in analytics.
- Switch to updated QUIC framework.

KNOWN ISSUES
    No known issues.



19.31 - 2018-07-12

- Distinguish pre-positioning from pre-caching in analytics.
- Distinguish OS cache content from network downloads in analytics.

KNOWN ISSUES
    No known issues.



19.23 - 2018-07-03

- Add custom mPulse timers via startEvent/stopEvent.
- Increase Universal Cache file size limit to 3 MB.
- Expanded error reporting for connection failures.

KNOWN ISSUES
    No known issues.



19.22 - 2018-05-10

- Includes integration with mPulse dashboard through optional framework.
- Added 'debugSendAnalytics' call to send URL and custom event records immediately.

KNOWN ISSUES
    No known issues.



19.21 - 2018-04-12

- Framework is now built with Bitcode.

KNOWN ISSUES
    No known issues.



19.13 - 2018-03-15

- Added support for auto-joined segments.
- Improved feedback by sending analytics records more regularly.
- Reduced SDK size.

KNOWN ISSUES
    No known issues.



19.12 - 2018-02-08

- Added delegate callback for custom TLS certificate handling

KNOWN ISSUES
    No known issues.



19.11 - 2018-01-24

- Image Manager support.
- Bug fixes.

KNOWN ISSUES
    No known issues.



18.43 - 2017-01-22

- Bug fixes.

KNOWN ISSUES
    No known issues.



18.42 - 2018-01-18

- Fixed handling of untrusted SSL certificates.

KNOWN ISSUES
    No known issues.


18.42 - 2017-12-14

- Fixed duplication of User-Agent: header.
- Made Universal Cache respect offline content policy.
- Fixed initial sync sometimes does not start for a long time.

KNOWN ISSUES
    No known issues.


18.42 - 2017-11-30

- New config property VocService.config.foregroundContentCheckDelay - seconds after coming
	to foreground to delay a check for new content. This delay helps reduce interference
	with time-critical tasks such as UI setup.  Default value is 3.0 seconds.	
	
- Bug fixes.

KNOWN ISSUES
    No known issues.



18.41 - 2017-11-15

- Fixed sometimes download will not resume after app crash.


18.41 - 2017-11-08

- Bug fixes.


18.41 - 2017-10-20

- Bug fixes.


18.33 - 2017-11-07

- Bug fixes


18.33 - 2017-09-20

- QUIC support.
- Bug fixes.

KNOWN ISSUES
    No known issues.



18.32 - 2017-08-10

- Backend optimizations.
- Bug fixes.


18.31 - 2017-07-26

- Backend optimizations.
- Enabling debug console shows licensed capabilities as the server changes them.
- Delete analytics data unsent for one week to prevent accumulation.
- Allow POST redirects to become GET to match most browsers.


DEPRECATIONS

- registerWithLicense (instead use configuration dictionary in Info.plist)
- VocConfig::networkSelection is marked readonly in this release and
        the value it holds reflect the applied network selection.
        Use VocConfig::networkSelectionOverride for writing the value.


18.22 - 2017-06-13


- Improvements in network quality detection.
- SDK will no longer cause location prompt and will monitor location only if app
	requests and is granted authorization to use location.


DEPRECATIONS

- Following enums are deprecated
	VOCItemState.VocItemQueued (instead use VOCItemQueued)
	VOCItemState.VocItemIdle (instead use VOCItemIdle)
	VOCItemState.VocItemPaused (instead use VOCItemPaused)
	VOCItemState.VocItemFailed (instead use VOCItemFailed)

- Following method is deprecated
	VocService.getItemWithContentId:completion:
		use VocService::getItemsWithContentIds:contentIds:sourceName:completion: instead.
	VocService.addDownloadedItem:completion:
		use VocService.addDownloadedItem:completion: instead.

- Following property is deprecated
	VocItem.downloadingNow
