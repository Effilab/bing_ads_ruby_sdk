# Test Strategy

A test strategy defines how we approach automated testing: goals, scope, methods, priorities, and tools. It keeps test decisions consistent and makes regressions easy to detect.

## 1. Purpose of Testing

Our tests serve three goals:

1. Verify requirements
2. Prevent regressions
3. Document current behavior

Good tests are readable, fast, and focused on behavior rather than implementation details.

## 2. Coverage Principles

Automated tests should back every feature and behavior change. Prioritize:

- Core business logic
- Error handling paths
- Boundary conditions
- Integration points outside the object under test

Avoid testing framework internals or implementation details that do not affect behavior.

## 3. Test Levels

### Unit tests

Unit tests validate a single responsibility in isolation.

Use them for:
- Validation logic
- Transformation logic
- Domain rules
- Object interaction contracts

Keep examples small and deterministic.

### Service tests

Service tests cover orchestration and collaboration between objects.

Use them for:
- Multi-step workflows
- API/client orchestration
- Error propagation
- Success and failure paths

### Integration tests

Integration tests cover the boundaries where your code talks to external systems or real collaborators.

Use them for:
- HTTP clients
- File IO
- External APIs
- Real database or cache interactions when appropriate

## 4. Test Design Rules

- One behavior per example
- Use names that describe observable outcomes
- Prefer real behavior over mock-only assertions
- Stub external boundaries, not internal implementation details
- Keep fixtures and factories minimal
- Avoid shared mutable state between examples

## 5. Assertions

Prefer expectations that express behavior clearly:

- `expect(actual).to eq(expected)`
- `expect(value).to be_nil`
- `expect(condition).to be(false)`
- `expect { ... }.to raise_error(ErrorClass)`
- `expect(collection).to include(value)`

Choose assertions that verify the contract, not the implementation.

## 6. Example Structure

```ruby
RSpec.describe ExampleService do
  describe '.call' do
    it 'returns success when the input is valid' do
      result = described_class.call(value: 'ok')

      expect(result.status).to eq(:success)
    end

    it 'returns an error when the input is invalid' do
      result = described_class.call(value: nil)

      expect(result.success?).to be(false)
      expect(result.error).to eq('value is required')
    end
  end
end
```

## 7. TDD Workflow

1. Write the failing spec
2. Run the focused test and confirm the failure
3. Implement the minimum change to satisfy it
4. Re-run the focused test
5. Refactor without changing behavior
6. Run the relevant suite before finishing

## 8. File Organization

A simple Ruby project might look like this:

```text
spec/
  unit/
  services/
  integration/
  support/
```

## 9. Final Rule

Prefer the smallest test that checks the contract. If the assertion does not say what the user or caller should observe, it is probably testing too much.
