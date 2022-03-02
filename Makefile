include .env

default: install

up:
	@docker-compose up -d $(filter-out $@,$(MAKECMDGOALS))

down:
	@docker-compose down -v $(filter-out $@,$(MAKECMDGOALS))

prune: down

start:
	@docker-compose start $(filter-out $@,$(MAKECMDGOALS))

stop:
	@docker-compose stop $(filter-out $@,$(MAKECMDGOALS))

ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

sh:
	@docker-compose exec $(or $(filter-out $@,$(MAKECMDGOALS)), 'php') sh

bash:
	@docker-compose exec $(or $(filter-out $@,$(MAKECMDGOALS)), 'php') bash

shell: bash

composer:
	@docker-compose exec php composer $(filter-out $@,$(MAKECMDGOALS))

drush:
	@docker-compose exec php vendor/bin/drush $(filter-out $@,$(MAKECMDGOALS))

install:
	@docker-compose down -v
	@docker-compose up -d
	@docker-compose exec php composer install
	@sleep 30
	@docker-compose exec php vendor/bin/drush -y si standard
	@docker-compose exec php vendor/bin/drush cr
	@docker-compose exec php vendor/bin/drush -y en devel examples adminimal_admin_toolbar
	@docker-compose exec php vendor/bin/drush -y then adminimal_theme
	@docker-compose exec php vendor/bin/drush -y cset system.theme admin adminimal_theme
	@docker-compose exec php vendor/bin/drush -y cset system.theme default adminimal_theme
	@docker-compose exec php vendor/bin/drush uli
	@docker-compose exec php sudo chmod -R 777 /var/www/html
	@git config core.fileMode false
