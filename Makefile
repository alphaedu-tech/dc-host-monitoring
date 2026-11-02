# Makefile
include makefile_docker_compose.mk

.PHONY: format f

VOLUME_DIRS := \
	.docker_volumes/prometheus/data \
	.docker_volumes/grafana/data \
	.docker_volumes/loki/data \
	.docker_volumes/loki/wal \
	.docker_volumes/loki/compactor

# Override up to create directories with proper permissions — only on first start.
# После первого запуска папки сервисов принадлежат их uid (prometheus — nobody,
# grafana — 472) и бывают закрыты (700): пользователь хоста в них не проходит,
# и безусловный `mkdir -p` падал, хотя всё на месте. 14.10.2026 так `make d`
# остановил стек на обоих продах и не поднял его. Папку пропускаем, если она
# есть или если её родитель уже существует, но закрыт для нас.
up:
	@for d in $(VOLUME_DIRS); do \
		p=$$(dirname "$$d"); \
		if [ -e "$$p" ] && [ ! -x "$$p" ]; then continue; fi; \
		[ -d "$$d" ] || { mkdir -p "$$d" && chmod 777 "$$d"; } || exit 1; \
	done
	$(DC_BIN) up -d

format:
	prettier --write .

f: format
