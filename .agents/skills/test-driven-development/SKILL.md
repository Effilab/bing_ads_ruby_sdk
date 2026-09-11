---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development (TDD)

## Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you did not watch the test fail, you do not know whether it tests the right behavior.

## When to Use

**Always:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask your human partner):**
- Throwaway prototypes
- Generated code
- Configuration files

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it and start over.

## Red-Green-Refactor

```text
RED -> write failing test
GREEN -> minimal implementation
REFACTOR -> clean up without changing behavior
```

### RED - Write Failing Test

Write one minimal test showing the intended behavior.

```ruby
RSpec.describe '#retry_operation' do
  it 'retries until the operation succeeds' do
    attempts = 0
    operation = lambda do
      attempts += 1
      raise 'fail' if attempts < 3
      'success'
    end

    result = retry_operation(operation)

    expect(result).to eq('success')
    expect(attempts).to eq(3)
  end
end
```

### Verify RED

```bash
bundle exec rspec spec/retry_operation_spec.rb
```

Confirm:
- The test fails for the expected reason
- It is failing because the feature is missing, not because of a typo or setup bug

### GREEN - Minimal Code

```ruby
def retry_operation(operation, max_attempts: 3)
  attempts = 0

  begin
    operation.call
  rescue StandardError
    attempts += 1
    retry if attempts < max_attempts
    raise
  end
end
```

### Verify GREEN

```bash
bundle exec rspec spec/retry_operation_spec.rb
```

Confirm:
- The test passes
- Other relevant tests still pass
- Output is clean

### REFACTOR

Only after the test passes:
- Remove duplication
- Improve names
- Extract helpers

Keep behavior unchanged.

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| Minimal | One behavior per example | `it 'validates email and domain and whitespace'` |
| Clear | Describes observable behavior | `it 'test1'` |
| Real | Exercises real code | Tests mock setup instead of behavior |

## Why Order Matters

Test-first prevents false confidence. If the test is written after the code, you can easily test what you already implemented rather than what the behavior requires.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code still breaks; tests are cheap |
| "I'll test after" | Tests-after are biased by implementation |
| "Already manually tested it" | Manual checks are not repeatable evidence |
| "Deleting X hours is wasteful" | Keeping unverified code is technical debt |

## Red Flags - Stop and Start Over

- Code before test
- Test passes immediately without proving the bug
- Test is written to match the implementation instead of the contract
- You cannot explain why the test failed
- You are adapting an existing implementation rather than writing a failing specification

## Example: Bug Fix

**Bug:** Empty email accepted

**RED**

```ruby
class User
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def valid?
    !email.to_s.strip.empty?
  end
end
```

```ruby
RSpec.describe User do
  describe '#valid?' do
    it 'rejects an empty email' do
      user = User.new('')

      expect(user.valid?).to be(false)
    end
  end
end
```

**GREEN**

```ruby
class User
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def valid?
    !email.to_s.strip.empty?
  end
end
```

## Verification Checklist

Before marking work complete:

- [ ] Every new function or method has a test
- [ ] The test fails before implementation
- [ ] The failure matches the missing behavior
- [ ] The implementation is minimal and targeted
- [ ] Relevant tests pass after the fix
- [ ] No unnecessary mock-only assertions were added

## Final Rule

```
Production code → test exists and failed first
Otherwise → not TDD
```
