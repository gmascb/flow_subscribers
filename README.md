# FlowSubscribers

A Ruby gem that implements the **Flow Pattern** for organizing backend code following **SOLID principles**.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flow_subscribers'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install flow_subscribers
```

---

## Architecture

O **FlowSubscribers** implementa dois padrões de fluxo para organizar lógica de negócio:

### Visão Geral das Classes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MÓDULO Flows                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────┐    ┌─────────────────────────────────────┐ │
│  │      SIMPLE FLOW            │    │         COMPLETE FLOW               │ │
│  │                             │    │                                     │ │
│  │  ┌───────────────────────┐  │    │  ┌─────────────────────────────┐    │ │
│  │  │ SimpleFlowController  │  │    │  │  CompleteFlowController     │    │ │
│  │  │                       │  │    │  │                             │    │ │
│  │  │  - flows[]            │  │    │  │  - flows[]                  │    │ │
│  │  │  - flow_context       │  │    │  │  - flow_context             │    │ │
│  │  │  - transactional      │  │    │  │  - transactional            │    │ │
│  │  └───────────┬───────────┘  │    │  └──────────────┬──────────────┘    │ │
│  │              │              │    │                 │                   │ │
│  │              ▼              │    │                 ▼                   │ │
│  │  ┌───────────────────────┐  │    │  ┌─────────────────────────────┐    │ │
│  │  │ SimpleFlowSubscriber  │  │    │  │  CompleteFlowSubscriber     │    │ │
│  │  │                       │  │    │  │                             │    │ │
│  │  │  + run(context)       │  │    │  │  + can_execute?(context)    │    │ │
│  │  │  + execute(context)   │  │    │  │  + valid?(context)          │    │ │
│  │  └───────────┬───────────┘  │    │  │  + prepare(context)         │    │ │
│  │              │              │    │  │  + save(context)            │    │ │
│  │              │ extends      │    │  │  + dispose(context)         │    │ │
│  │              ▼              │    │  └─────────────────────────────┘    │ │
│  │  ┌───────────────────────┐  │    │                                     │ │
│  │  │SimpleCatchFlowSubscrib│  │    │                                     │ │
│  │  │                       │  │    │                                     │ │
│  │  │  + execute(context)   │  │    │                                     │ │
│  │  │  + catch(err, context)│  │    │                                     │ │
│  │  └───────────────────────┘  │    │                                     │ │
│  └─────────────────────────────┘    └─────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Fluxo de Comunicação - Simple Flow

O **SimpleFlow** executa cada subscriber sequencialmente. Ideal para fluxos simples onde cada etapa depende da anterior.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        SimpleFlowController                                  │
│                      ┌─────────┘                                             │
│                      ▼                                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │  LOOP: Para cada flow em @flows                                       │   │
│  │                                                                       │   │
│  │    ┌─────────────────┐     ┌─────────────────┐     ┌──────────────┐   │   │
│  │    │  Subscriber A   │ ──► │  Subscriber B   │ ──► │ Subscriber C │   │   │
│  │    │       │         │     │       │         │     │      │       │   │   │
│  │    │       ▼         │     │       ▼         │     │      ▼       │   │   │
│  │    │ execute(context)│     │ execute(context)│     │execute(ctx)  │   │   │
│  │    └─────────────────┘     └─────────────────┘     └──────────────┘   │   │
│  │                                                                       │   │
│  │    flow_context é passado e modificado em cada etapa                  │   │
│  │    ──────────────────────────────────────────────────────────────►    │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Retorna: flow_context (com todas as modificações)                           │
└──────────────────────────────────────────────────────────────────────────────┘
```

**SimpleCatchFlowSubscriber** adiciona tratamento de exceções:

```
┌─────────────────────────────────────────────────────────────┐
│              SimpleCatchFlowSubscriber                      │
│                                                             │
│   run(flow_context)                                         │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────┐                                   │
│   │  try                │                                   │
│   │    execute(context) │────► Sucesso ────► return context │
│   └─────────┬───────────┘                                   │
│             │                                               │
│        Exception?                                           │
│             │                                               │
│             ▼                                               │
│   ┌─────────────────────┐                                   │
│   │  catch              │                                   │
│   │    catch(err, ctx)  │────► return context               │
│   └─────────────────────┘                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Fluxo de Comunicação - Complete Flow

O **CompleteFlow** executa em **5 fases distintas**, onde cada fase é executada para TODOS os subscribers antes de avançar para a próxima. Ideal para lógica de negócio complexa com validações, preparações e rollback.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                       CompleteFlowController                                 │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                                                                       │   │
│  │   FASE 1: can_execute? (Determina quais flows vão executar)           │   │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │   │
│  │   │ Subscriber A │  │ Subscriber B │  │ Subscriber C │               │   │
│  │   │can_execute?()│  │can_execute?()│  │can_execute?()│               │   │
│  │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘               │   │
│  │          │ true            │ true            │ false                  │   │
│  │          ▼                 ▼                 ✗ (ignorado)             │   │
│  │                                                                       │   │
│  │   FASE 2: valid? (Valida TODOS os executáveis)                        │   │
│  │   ┌──────────────┐  ┌──────────────┐                                  │   │
│  │   │ Subscriber A │  │ Subscriber B │   Se exception ──► PARA TUDO    │   │
│  │   │   valid?()   │  │   valid?()   │                                  │   │
│  │   └──────┬───────┘  └──────┬───────┘                                  │   │
│  │          ▼                 ▼                                          │   │
│  │                                                                       │   │
│  │   FASE 3: prepare (Prepara dados para todos)                          │   │
│  │   ┌──────────────┐  ┌──────────────┐                                  │   │
│  │   │ Subscriber A │  │ Subscriber B │                                  │   │
│  │   │  prepare()   │  │  prepare()   │                                  │   │
│  │   └──────┬───────┘  └──────┬───────┘                                  │   │
│  │          ▼                 ▼                                          │   │
│  │                                                                       │   │
│  │   FASE 4: save (Persiste dados para todos)                            │   │
│  │   ┌──────────────┐  ┌──────────────┐                                  │   │
│  │   │ Subscriber A │  │ Subscriber B │                                  │   │
│  │   │    save()    │  │    save()    │                                  │   │
│  │   └──────┬───────┘  └──────┬───────┘                                  │   │
│  │          ▼                 ▼                                          │   │
│  │                                                                       │   │
│  │   FASE 5: dispose (Finaliza/Notifica todos)                           │   │
│  │   ┌──────────────┐  ┌──────────────┐                                  │   │
│  │   │ Subscriber A │  │ Subscriber B │                                  │   │
│  │   │  dispose()   │  │  dispose()   │                                  │   │
│  │   └──────────────┘  └──────────────┘                                  │   │
│  │                                                                       │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Retorna: flow_context (com resultados de todas as fases)                    │
└──────────────────────────────────────────────────────────────────────────────┘
```


### Comparação: Simple vs Complete Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   SIMPLE FLOW                        COMPLETE FLOW                          │
│   ───────────                        ─────────────                          │
│                                                                             │
│   Subscriber A                       FASE 1: can_execute?                   │
│       │ execute()                        A ──► B ──► C (C returned false)   │
│       ▼                                                                     │
│   Subscriber B                       FASE 2: valid?                         │
│       │ execute()                        A ──► B     C doesn't execute any  │
│       ▼                                                 other step          │
│   Subscriber C                       FASE 3: prepare                        │
│       │ execute()                        A ──► B                            │
│       ▼                                                                     │
│   FIM                                FASE 4: save                           │
│                                          A ──► B                            │
│                                                                             │
│   Execução:                          FASE 5: dispose                        │
│   SEQUENCIAL por subscriber              A ──► B                            │
│   A completo ► B completo ► C                                               │
│                                      Execução:                              │
│   Use quando:                        TODAS AS FASES para todos              │
│   - Fluxos simples                   antes de avançar                       │
│   - Cada etapa depende da anterior                                          │
│   - Tratamento de erro individual    Use quando:                            │
│                                      - Validações complexas                 │
│                                      - Rollback transacional                │
│                                      - Múltiplos subscribers                │
│                                        interdependentes                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Fluxo do flow_context

O `flow_context` é um Hash compartilhado que flui por todos os subscribers:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                          flow_context                                      │
│                                                                            │
│   Entrada:  { user_id: 1, amount: 100 }                                    │
│                    │                                                       │
│                    ▼                                                       │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Subscriber A (ValidateBalance)                                     │  │
│   │  context[:sender] = User.find(...)                                  │  │
│   │  context[:sender_balance_before] = 500                              │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                    │                                                       │
│                    ▼                                                       │
│   { user_id: 1, amount: 100, sender: <User>, sender_balance_before: 500 }  │
│                    │                                                       │
│                    ▼                                                       │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Subscriber B (ExecuteTransfer)                                     │  │
│   │  context[:transfer] = Transfer.create!(...)                         │  │
│   │  context[:transfer_id] = 42                                         │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                    │                                                       │
│                    ▼                                                       │
│   { user_id: 1, amount: 100, sender: <User>, sender_balance_before: 500,   │
│     transfer: <Transfer>, transfer_id: 42 }                                │
│                    │                                                       │
│                    ▼                                                       │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Subscriber C (SendReceipt)                                         │  │
│   │  context[:receipt_sent] = true                                      │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                    │                                                       │
│                    ▼                                                       │
│   Saída:  { user_id: 1, amount: 100, sender: <User>, ..., receipt: true }  │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## Simple Flow

Recommended for most use cases. Simple and straightforward.

### Example of SimpleFlowController

```ruby
class CreateAccountFlowController < Flows::SimpleFlowController
  def initialize(flow_context:, transactional: false)
    super(
      flows: [
        ValidateInputFlowSubscriber.new,
        CreateAccountFlowSubscriber.new,
        SendWelcomeEmailFlowSubscriber.new
      ],
      flow_context: flow_context,
      transactional: transactional
    )
  end
end
```

### SimpleFlowSubscribers

```ruby
class ValidateInputFlowSubscriber < Flows::SimpleFlowSubscriber
  def execute(flow_context)
    raise "Email is required" unless flow_context[:email]
    raise "Name is required" unless flow_context[:name]
  end
end

class CreateAccountFlowSubscriber < Flows::SimpleCatchFlowSubscriber
  def execute(flow_context)
    account = Account.create!(
      email: flow_context[:email],
      name: flow_context[:name]
    )
    flow_context[:account] = account
  end

  def catch(exception, flow_context)
    flow_context[:error] = exception.message
    flow_context[:success] = false
  end
end

class SendWelcomeEmailFlowSubscriber < Flows::SimpleFlowSubscriber
  def execute(flow_context)
    return if flow_context[:error]  # Skip if previous flow failed
    AccountMailer.welcome(flow_context[:account]).deliver_later
    flow_context[:email_sent] = true
  end
end
```

### Usage in Rails API Controller

```ruby
class AccountsController < ApplicationController
  def create
    result = CreateAccountFlowController.new(
      flow_context: {
        email: params[:email],
        name: params[:name]
      },
      transactional: true
    ).execute

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: { account: result[:account] }, status: :created
    end
  end
end
```

---

## Complete Flow (For complex business logic)

The controller executes **each phase for ALL flows** before moving to the next phase.

### Example: CompleteFlowController

```ruby
class BankTransferFlowController < Flows::CompleteFlowController
  def initialize(flow_context:, transactional: false)
    super(
      flows: [
        ValidateBalanceFlowSubscriber.new,
        ExecuteTransferFlowSubscriber.new,
        SendSenderReceiptFlowSubscriber.new,
        SendReceiverReceiptFlowSubscriber.new
      ],
      flow_context: flow_context,
      transactional: transactional
    )
  end
end
```

### Flow Execution Order

```
Phase 1: can_execute?
├── ValidateBalanceFlowSubscriber.can_execute?     ✓ (user_id, amount present)
├── ExecuteTransferFlowSubscriber.can_execute?     ✓ (sender, bank, agency, number present)
├── SendSenderReceiptFlowSubscriber.can_execute?   ✓ (transfer_id, sender present)
└── SendReceiverReceiptFlowSubscriber.can_execute? ✓ (transfer_id, receiver present)

Phase 2: valid?
├── ValidateBalanceFlowSubscriber.valid?     → Validates balance, loads sender
├── ExecuteTransferFlowSubscriber.valid?     → Validates destination, loads receiver
├── SendSenderReceiptFlowSubscriber.valid?   → Validates transfer_id and sender
└── SendReceiverReceiptFlowSubscriber.valid? → Validates transfer_id and receiver

Phase 3: prepare
├── ValidateBalanceFlowSubscriber.prepare     → Calculates new balance
├── ExecuteTransferFlowSubscriber.prepare     → Prepares transfer data
├── SendSenderReceiptFlowSubscriber.prepare   → Prepares sender receipt
└── SendReceiverReceiptFlowSubscriber.prepare → Prepares receiver receipt

Phase 4: save (only if ALL validations passed!)
├── ValidateBalanceFlowSubscriber.save        → Nothing
├── ExecuteTransferFlowSubscriber.save        → Updates balances, creates transfer
├── SendSenderReceiptFlowSubscriber.save      → Creates sender receipt
└── SendReceiverReceiptFlowSubscriber.save    → Creates receiver receipt

Phase 5: dispose
├── ValidateBalanceFlowSubscriber.dispose        → Nothing
├── ExecuteTransferFlowSubscriber.dispose        → Logs transfer
├── SendSenderReceiptFlowSubscriber.dispose      → Sends email to sender
└── SendReceiverReceiptFlowSubscriber.dispose    → Sends email + notification to receiver
```

### FlowSubscriber 1: Validate Balance

```ruby
class ValidateBalanceFlowSubscriber < Flows::CompleteFlowSubscriber
  def can_execute?(flow_context)
    flow_context[:user_id].present? && flow_context[:amount].present?
  end

  def valid?(flow_context)
    raise "user_id is required" unless flow_context[:user_id].present?
    raise "amount is required" unless flow_context[:amount].present?
    raise "amount must be positive" if flow_context[:amount] <= 0

    sender = User.find(flow_context[:user_id])
    raise "Insufficient balance" if sender.balance < flow_context[:amount]

    flow_context[:sender] = sender
    flow_context[:sender_balance_before] = sender.balance
  end

  def prepare(flow_context)
    flow_context[:sender_balance_after] = flow_context[:sender_balance_before] - flow_context[:amount]
  end

  def save(flow_context)
    # Nothing to save yet
  end

  def dispose(flow_context)
    # Nothing to dispose
  end
end
```

### FlowSubscriber 2: Execute Transfer

```ruby
class ExecuteTransferFlowSubscriber < Flows::CompleteFlowSubscriber
  def can_execute?(flow_context)
    flow_context[:sender].present? &&
      flow_context[:bank].present? &&
      flow_context[:agency].present? &&
      flow_context[:number].present?
  end

  def valid?(flow_context)
    destination_account = BankAccount.find_by(
      bank: flow_context[:bank],
      agency: flow_context[:agency],
      number: flow_context[:number]
    )
    raise "Destination account not found" unless destination_account

    flow_context[:destination_account] = destination_account
    flow_context[:receiver] = destination_account.user
  end

  def prepare(flow_context)
    flow_context[:transfer_data] = {
      sender_id: flow_context[:sender].id,
      receiver_id: flow_context[:receiver].id,
      destination_bank: flow_context[:bank],
      destination_agency: flow_context[:agency],
      destination_number: flow_context[:number],
      amount: flow_context[:amount],
      status: :pending
    }
  end

  def save(flow_context)
    flow_context[:sender].update!(balance: flow_context[:sender_balance_after])

    new_receiver_balance = flow_context[:receiver].balance + flow_context[:amount]
    flow_context[:receiver].update!(balance: new_receiver_balance)

    transfer = Transfer.create!(flow_context[:transfer_data].merge(status: :completed))
    flow_context[:transfer] = transfer
    flow_context[:transfer_id] = transfer.id
  end

  def dispose(flow_context)
    Rails.logger.info("Transfer ##{flow_context[:transfer_id]} completed")
  end
end
```

### FlowSubscriber 3: Send Receipt to Sender

```ruby
class SendSenderReceiptFlowSubscriber < Flows::CompleteFlowSubscriber
  def can_execute?(flow_context)
    flow_context[:transfer_id].present? && flow_context[:sender].present?
  end

  def valid?(flow_context)
    raise "transfer_id is required" unless flow_context[:transfer_id].present?
    raise "sender is required" unless flow_context[:sender].present?
  end

  def prepare(flow_context)
    flow_context[:sender_receipt] = {
      transfer_id: flow_context[:transfer_id],
      user_id: flow_context[:sender].id,
      type: :debit,
      amount: flow_context[:amount],
      balance_before: flow_context[:sender_balance_before],
      balance_after: flow_context[:sender_balance_after],
      destination: "#{flow_context[:bank]}/#{flow_context[:agency]}/#{flow_context[:number]}"
    }
  end

  def save(flow_context)
    receipt = Receipt.create!(flow_context[:sender_receipt])
    flow_context[:sender_receipt_id] = receipt.id
  end

  def dispose(flow_context)
    TransferMailer.sender_receipt(
      user: flow_context[:sender],
      transfer: flow_context[:transfer],
      receipt_id: flow_context[:sender_receipt_id]
    ).deliver_later
  end
end
```

### FlowSubscriber 4: Send Receipt to Receiver

```ruby
class SendReceiverReceiptFlowSubscriber < Flows::CompleteFlowSubscriber
  def can_execute?(flow_context)
    flow_context[:transfer_id].present? && flow_context[:receiver].present?
  end

  def valid?(flow_context)
    raise "transfer_id is required" unless flow_context[:transfer_id].present?
    raise "receiver is required" unless flow_context[:receiver].present?
  end

  def prepare(flow_context)
    flow_context[:receiver_receipt] = {
      transfer_id: flow_context[:transfer_id],
      user_id: flow_context[:receiver].id,
      type: :credit,
      amount: flow_context[:amount],
      sender_name: flow_context[:sender].name
    }
  end

  def save(flow_context)
    receipt = Receipt.create!(flow_context[:receiver_receipt])
    flow_context[:receiver_receipt_id] = receipt.id
  end

  def dispose(flow_context)
    TransferMailer.receiver_receipt(
      user: flow_context[:receiver],
      transfer: flow_context[:transfer],
      receipt_id: flow_context[:receiver_receipt_id]
    ).deliver_later

    NotificationService.notify(
      flow_context[:receiver].id,
      "You received #{flow_context[:amount]} from #{flow_context[:sender].name}"
    )
  end
end
```

### Usage in Rails API Controller

```ruby
class TransfersController < ApplicationController
  def create
    result = BankTransferFlowController.new(
      flow_context: {
        user_id: current_user.id,
        amount: params[:amount].to_f,
        bank: params[:bank],
        agency: params[:agency],
        number: params[:number]
      },
      transactional: true
    ).execute

    if result[:transfer_id]
      render json: {
        transfer_id: result[:transfer_id],
        sender_receipt_id: result[:sender_receipt_id],
        receiver_receipt_id: result[:receiver_receipt_id]
      }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end
```

---

## Transactional Mode

**When `transactional: true` in CompleteFlowController:**
- All 5 phases are wrapped in a single transaction
- If validation fails in Phase 2, no saves are executed (no rollback needed)
- If an error occurs in Phase 4 (save), all previous saves are rolled back
- Commit only happens after Phase 5 (dispose) completes

### Use Cases for Transactional Mode

- When multiple flows modify the database and you need atomicity
- When you need "all or nothing" behavior
- When you want automatic rollback on failure
- When nested flows all need to succeed or fail together

---

## SOLID Principles Applied

- **S** (Single Responsibility): Each FlowSubscriber has ONE responsibility
- **O** (Open/Closed): Extend by creating new subscribers, don't modify existing ones
- **L** (Liskov Substitution): Any FlowSubscriber can be replaced by another
- **I** (Interface Segregation): Simple interface - just implement required methods
- **D** (Dependency Inversion): Dependencies injected via constructor

---

## Best Practices

### 1. Keep execute methods short (~20 lines max)

If it grows, split into multiple FlowSubscribers.

### 2. Each FlowSubscriber should have one responsibility

```
Validation → ValidateInputFlowSubscriber
Transformation → TransformDataFlowSubscriber
Persistence → SaveResultFlowSubscriber
Notification → SendEmailFlowSubscriber
```

### 3. Use flow_context to pass data between flows

```ruby
# First flow
flow_context[:user] = User.find(id)

# Next flow can access
user = flow_context[:user]
```

### 4. Inject dependencies via constructor

```ruby
class FindUserFlowSubscriber < Flows::SimpleFlowSubscriber
  def initialize(repository:)
    @repository = repository
    super()
  end

  def execute(flow_context)
    flow_context[:user] = @repository.find(flow_context[:user_id])
  end
end
```

---

## Methods to Implement

### SimpleFlowSubscriber

| Method | Description |
|--------|-------------|
| `execute(flow_context)` | Main business logic |

### SimpleCatchFlowSubscriber

| Method | Description |
|--------|-------------|
| `execute(flow_context)` | Main business logic |
| `catch(exception, flow_context)` | Exception handler |

### CompleteFlowSubscriber

| Method | Description |
|--------|-------------|
| `can_execute?(flow_context)` | Return boolean to determine if flow should run |
| `valid?(flow_context)` | Validate data, raise exception if invalid |
| `prepare(flow_context)` | Prepare data, calculations, transformations |
| `save(flow_context)` | Persist data, HTTP requests, database operations |
| `dispose(flow_context)` | Cleanup, notifications, queue messages |

---

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gmascb/flow_subscribers.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
