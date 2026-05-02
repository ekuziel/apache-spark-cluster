.PHONY: help init build build-kafka up kafka up-kafka up-gluten down logs logs-kafka status clean data notebook kafka-topics nuke nb-count

JUPYTER_URL  := http://localhost:8888
SCALE        ?= 1

help:
	@echo "Available commands:"
	@echo "  make init          create local directories"
	@echo "  make build         docker compose build"
	@echo "  make build-kafka   build Kafka broker image"
	@echo "  make up            start cluster in vanilla mode"
	@echo "  make up kafka      start vanilla cluster, then Kafka + Kafka UI"
	@echo "  make up-kafka      start vanilla cluster with Kafka profile"
	@echo "  make up-gluten     start cluster with Gluten/Velox enabled"
	@echo "  make down          stop cluster"
	@echo "  make logs          tail spark-master logs"
	@echo "  make logs-kafka    tail Kafka logs"
	@echo "  make status        docker compose ps"
	@echo "  make data          generate benchmark data (SCALE=1)"
	@echo "  make clean         stop + delete all data"
	@echo "  make notebook      open JupyterLab in browser"
	@echo "  make kafka-topics  list Kafka topics"
	@echo "  make nb-count      count all .ipynb files in notebooks folder"
	@echo ""

init:
	mkdir -p data notebooks/results spark-events
	touch data/.gitkeep spark-events/.gitkeep
	@if [ ! -f .env ]; then cp .env.example .env && echo "Created .env from .env.example"; fi
	@echo "Directories created."

build:
	docker compose build

build-kafka:
	docker compose --profile kafka build kafka

up: init
	docker compose up -d
	@echo ""
	@echo "  Spark Master UI  →  http://localhost:8080"
	@echo "  History Server   →  http://localhost:18080"
	@echo "  JupyterLab       →  http://localhost:8888  (token: spark)"
	@echo ""
	@echo "Run 'make logs' to watch startup."

# Optional Kafka profile. Supports: make up kafka
kafka: init
	docker compose --profile kafka up -d kafka kafka-ui
	@echo ""
	@echo "  Kafka broker     →  kafka:9092 from Docker network"
	@echo "  Kafka broker     →  localhost:9094 from host"
	@echo "  Kafka UI         →  http://localhost:8090"
	@echo ""

up-kafka: init
	docker compose --profile kafka up -d
	@echo ""
	@echo "  Spark Master UI  →  http://localhost:8080"
	@echo "  History Server   →  http://localhost:18080"
	@echo "  JupyterLab       →  http://localhost:8888  (token: spark)"
	@echo "  Kafka broker     →  kafka:9092 from Docker network"
	@echo "  Kafka broker     →  localhost:9094 from host"
	@echo "  Kafka UI         →  http://localhost:8090"
	@echo ""

up-gluten: init
	GLUTEN_ENABLED=true docker compose up -d
	@echo ""
	@echo "  Gluten/Velox mode ENABLED"
	@echo "  Spark Master UI  →  http://localhost:8080"
	@echo "  JupyterLab       →  http://localhost:8888  (token: spark)"
	@echo ""

down:
	docker compose --profile kafka down

logs:
	docker compose logs -f spark-master

logs-kafka:
	docker compose --profile kafka logs -f kafka

status:
	docker compose --profile kafka ps

data:
	@echo "Generating benchmark data (SCALE=$(SCALE)) inside notebook container..."
	docker compose exec notebook jupyter nbconvert --to notebook --execute \
		--ExecutePreprocessor.timeout=300 \
		/workspace/notebooks/05_generate_benchmark_data.ipynb \
		--output /workspace/notebooks/05_generate_benchmark_data.ipynb
	@echo "Done — data ready in ./data/"

clean:
	docker compose --profile kafka down
	rm -rf data/*.parquet data/parquet data/delta data/iceberg data/hudi data/benchmark data/pipelines data/checkpoints
	rm -rf spark-events/*
	@echo "Data cleared. Docker volumes and notebook results kept."

notebook:
	@which xdg-open > /dev/null 2>&1 && xdg-open $(JUPYTER_URL) || \
	 which open      > /dev/null 2>&1 && open      $(JUPYTER_URL) || \
	 echo "Open $(JUPYTER_URL) in your browser  (token: spark)"

kafka-topics:
	docker compose --profile kafka exec kafka kafka-topics.sh --bootstrap-server localhost:9092 --list

nuke:
	docker compose --profile kafka down --rmi all --volumes --remove-orphans 2>/dev/null || true
	docker builder prune -f
	@echo "All images and cache removed. Run 'make build' to rebuild from scratch."

nb-count:
	@echo "Notebook count:" $$(find notebooks -type f -name "*.ipynb" ! -path "*/.ipynb_checkpoints/*" | wc -l)