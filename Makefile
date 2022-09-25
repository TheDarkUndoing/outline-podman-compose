oidc_server_container=wk-oidc-server

gen-conf:
	cd ./scripts && bash ./main.sh init_cfg

start:
	podman-compose up -d
	cd ./scripts && bash ./main.sh reload_nginx

install: gen-conf start
	sleep 1
	podman-compose exec ${oidc_server_container} bash -c "make init"
	podman-compose exec ${oidc_server_container} bash -c "python manage.py loaddata oidc-server-outline-client"
	cd ./scripts && bash ./main.sh reload_nginx

restart: stop start

logs:
	podman-compose logs -f

stop:
	podman-compose down || true

update-images:
	podman-compose pull

clean-docker: stop
	podman-compose rm -fsv || true

clean-conf:
	rm -rfv env.* .env docker-compose.yml config/uc/fixtures/*.json

clean-data: clean-docker
	rm -rfv ./data/certs ./data/minio_root ./data/pgdata ./data/uc

clean: clean-docker clean-conf
