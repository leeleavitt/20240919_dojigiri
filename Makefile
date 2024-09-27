include .env

install-mamba:
	@if ! command -v mamba &> /dev/null; then \
		echo "Mamba not found. Installing..."; \
		curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$$(uname)-$$(uname -m).sh"; \
		bash Miniforge3-$$(uname)-$$(uname -m).sh -b; \
		rm Miniforge3-$$(uname)-$$(uname -m).sh; \
	else \
		echo "Mamba is already installed."; \
	fi


venv: install-mamba
	@echo "Creating virtual environment..."
	@echo "Installing dependencies.."
	@mamba env create -f ~/git/shomei/services/backend/environment.yml -p .venv
	
	@echo "Installing shomei..."
	@make install-shomei
	
	@echo "Installing r-deps..." 
	@make install-r-deps
	
	@echo " Checking R dependencies..."
	@make check-r-deps

	@echo "Activating IRkernel..."
	@make activate-irkernel
	
	@echo "Done."

update-venv: install-mamba
	@echo "Updating virtual environment..."
	@echo "Installing dependencies.."
	@mamba env update -f ~/git/shomei/services/backend/environment.yml -p .venv
	


install-shomei:
	@if [ -d ~/git/shomei ]; then \
		echo "shomei repository exists. Installing..."; \
		.venv/bin/pip install -e ~/git/shomei/services/backend/; \
	else \
		echo "shomei repository does not exist. clone it to ~/git directory"; \
	fi


RSCRIPT = .venv/bin/Rscript
R = .venv/bin/R
ACTIVATE_ENV = . ~/miniforge3/bin/activate .venv/


install-r-deps:
	@echo "Installing samr..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install_github('teikobio/samr', ref='lee_dev', dependencies=TRUE)"
	@echo "Installing tokuprofile..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install_github(repo='teikobio/tokuprofile', ref='tokuprofile-2.0')"
	@echo "Installing CytoNorm..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install_github('saeyslab/CytoNorm', ref = '18bd294')"
	@echo "Installing grappolo..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install_github(repo='ParkerICI/grappolo')"
	@echo "Installing FastPG..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "BiocManager::install('sararselitsky/FastPG')"
	@echo "installing vite..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install_github('ParkerICI/vite')"
	@echo "Installing Spectre..." 
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install_github(repo = 'immunedynamics/spectre')"
	@ echo "Installing clustR..."
	$(ACTIVATE_ENV) && $(RSCRIPT) -e "devtools::install('~/git/shomei/services/backend/clustR')"



check-r-deps:
	@echo "Testing installs..."
	$(ACTIVATE_ENV) && $(R) -q -e "library('samr')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('tokuprofile')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('CytoNorm')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('grappolo')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('FastPG')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('vite')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('Spectre')"
	$(ACTIVATE_ENV) && $(R) -q -e "library('clustR')"
	@echo "Done."

activate-irkernel:
	@echo "Activating IRkernel..."
	$(ACTIVATE_ENV) && $(R) -q -e "IRkernel::installspec()"
	@echo "Done."
