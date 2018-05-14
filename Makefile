NAME = AUTRouting
PROJECT_NAME = ${NAME}.xcodeproj
SCHEME_NAME = ${NAME}

SIMULATOR = iphonesimulator11.3

.PHONY: bootstrap test

bootstrap:
	@carthage bootstrap --platform ios

test:
	@xcodebuild \
		-project ${PROJECT_NAME} \
		-scheme ${SCHEME_NAME} \
		-sdk ${SIMULATOR} build-for-testing
	@xctool \
		-project ${PROJECT_NAME} \
		-scheme ${SCHEME_NAME} \
		run-tests \
		-test-sdk ${SIMULATOR}
