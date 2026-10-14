NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

.PHONY: all up down start stop build clean fclean re

all:build
	@echo "Levantando infraestructura de $(NAME)"
	@docker compose -f $(COMPOSE_FILE) up -d

build: make_dirs
	@echo "Construyendo imagenes de docker"
	@docker compose -f $(COMPOSE_FILE) build

make_dirs:
	@@mkdir -p $(DATA_PATH)/maria_db
	@@mkdir -p $(DATA_PATH)/wordpress
	@echo "Directorios de datos verificados en $(DATA_PATH)"

down:
	@echo "Limpiando contenedores ...."
	@docker compose -f $(COMPOSE_FILE) down --rmi all --volumes

fclean:clean
	@echo "Eliminando carpetas fisicas en el host "
	@sudo rm -rf $(DATA_PATH)
	@echo "limpieza completada"

re: fclean all
