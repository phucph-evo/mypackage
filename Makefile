DIFF_EXECUTOR = ./bin/diff_executor
SRC_DIR = ./src
TEST_DIR = ./tests
VENDOR_BIN = vendor/bin
DEV_CONF = ./config/dev
check: cs 7cc test
MIGRATE_OPTION =
CODECEPT_TARGET= tests/old_codecept_unit/
CODECEPT_OPTIONS=
PHPUNIT_TARGET = tests/phpunit/
PHPUNIT_OPTIONS = -d memory_limit=1024M
PHPCS_OPTIONS=-d memory_limit=512M
cs-full:
	$(VENDOR_BIN)/phpcs $(PHPCS_OPTIONS) --standard=$(DEV_CONF)/phpcs-ruleset.xml -p -s $(SRC_DIR)
	$(VENDOR_BIN)/phpcs $(PHPCS_OPTIONS) --standard=$(DEV_CONF)/phpcs-ruleset.xml -p -s $(TEST_DIR)
cs:
	$(DIFF_EXECUTOR) -i "\.php$\" -e "(data/class|data/module|^html/|^build/)" '$(VENDOR_BIN)/phpcs $(PHPCS_OPTIONS) --standard=$(DEV_CONF)/phpcs-ruleset.xml -p -s'
cbf-full:
	$(VENDOR_BIN)/phpcbf --standard=$(DEV_CONF)/phpcs-ruleset.xml $(SRC_DIR)
	$(VENDOR_BIN)/phpcbf --standard=$(DEV_CONF)/phpcs-ruleset.xml $(TEST_DIR)
cbf:
	$(DIFF_EXECUTOR) -i "\.php$\" -e "(data/class|data/module|^build/)" '$(VENDOR_BIN)/phpcbf --standard=$(DEV_CONF)/phpcs-ruleset.xml'
md:
	$(VENDOR_BIN)/phpmd ./src text $(DEV_CONF)/phpmd-ruleset.xml
	$(VENDOR_BIN)/phpmd ./tests text $(DEV_CONF)/phpmd-ruleset.xml
7cc-full:
	$(VENDOR_BIN)/php7cc --extensions=php --level=info --relative-paths $(SRC_DIR)
	$(VENDOR_BIN)/php7cc --extensions=php --level=info --relative-paths $(TEST_DIR)
7cc:
	$(DIFF_EXECUTOR) -i "\.php$\" -e "(^html/|^build/)"  '$(VENDOR_BIN)/php7cc --level=error --extensions=php --relative-paths'
test:
	make phpunit
	make codecept
codecept:
	php vendor/bin/codecept run old_codecept_unit $(CODECEPT_OPTIONS) $(CODECEPT_TARGET)
phpunit:
	$(VENDOR_BIN)/phpunit $(PHPUNIT_OPTIONS) $(PHPUNIT_TARGET)
db-generate:
	$(VENDOR_BIN)/doctrine migrations:generate
db-migrate:
	$(VENDOR_BIN)/doctrine migrations:migrate $(MIGRATE_OPTION)
db-dry-migrate:
	$(VENDOR_BIN)/doctrine migrations:migrate --dry-run $(MIGRATE_OPTION)
db-rollback:
	$(VENDOR_BIN)/doctrine migrations:migrate prev
db-migration-status:
	$(VENDOR_BIN)/doctrine migrations:status
db-test-reload:
	yes | DOTENV_NAME=.env.test make db-migrate
db-test-hard-reload:
	mysql -u root -e "DROP SCHEMA giftmall_unit_test"
	mysql -u root -e "CREATE SCHEMA giftmall_unit_test DEFAULT CHARACTER SET utf8"
	yes | DOTENV_NAME=.env.test make db-migrate
clear-template-caches:
	rm -rf data/Smarty/templates_c/giftmall
	rm -rf data/Smarty/templates_c/giftmall_sp
	rm -rf data/Smarty/templates_c/giftmall_app_web_view
	rm -rf data/Smarty/templates_c/mobile
clear-admin-authority-cache:
	rm data/cache/mtb_authority_note.php
validate-resources:
	bin/console gm:resource:validate
build-css:
	npm run build-css
build-js:
	npm run build-js
stylelint:
	npm run stylelint
tslint:
	$(DIFF_EXECUTOR) -i "\.ts$\" -e "\.d.ts$\" 'npm run tslint'
tslint-full:
	npm run tslint:full
tslint-fix:
	$(DIFF_EXECUTOR) -i "\.ts$\" 'npm run tslint:fix'
protoc:
	rm -rf ./build/php/protobuf/*
	find ./resources/giftmall_api_protocol/proto -name "*.proto" | xargs protoc --php_out=./build/php/protobuf
