.PHONY: test spec install console clean build release help

# Default target
help:
	@echo "Available commands:"
	@echo "  make test      - Run all tests with RSpec"
	@echo "  make spec      - Alias for test"
	@echo "  make install   - Install gem dependencies"
	@echo "  make console   - Open interactive console"
	@echo "  make build     - Build the gem"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make release   - Release the gem"

# Run tests
test:
	bundle exec rspec

# Alias for test
spec: test

# Run specific test file
# Usage: make test-file FILE=spec/my_spec.rb
test-file:
	bundle exec rspec $(FILE)

# Run tests with documentation format
test-doc:
	bundle exec rspec --format documentation

# Run tests with coverage
test-coverage:
	COVERAGE=true bundle exec rspec

# Install dependencies
install:
	bundle install

# Open interactive console
console:
	bundle exec bin/console

# Build the gem
build:
	gem build flow_subscribers.gemspec

# Clean build artifacts
clean:
	rm -f *.gem
	rm -rf pkg/
	rm -rf coverage/

# Install gem locally
install-local: build
	gem install flow_subscribers-*.gem

# Release the gem
release:
	bundle exec rake release

