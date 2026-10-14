import 'dart:async';

import 'package:flutter/material.dart';

import '../game/checkout/checkout_session.dart';
import '../game/checkout/sale_transaction.dart';
import 'price_label.dart';

/// Prototype till. The session owns the totals; this widget only draws them.
class CheckoutPanel extends StatelessWidget {
  const CheckoutPanel({super.key, required this.session});

  final CheckoutSession session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (session.isOpen) {
          return _CheckoutCard(session: session);
        }
        final notice = session.notice;
        if (notice == null) {
          return const SizedBox.shrink();
        }
        return _SaleNotice(message: notice, onDone: session.dismissNotice);
      },
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.session});

  final CheckoutSession session;

  @override
  Widget build(BuildContext context) {
    final transaction = session.transaction;
    if (transaction == null) {
      return const SizedBox.shrink();
    }
    final paying = transaction.state == TransactionState.awaitingPayment;
    return Material(
      key: const Key('checkout-panel'),
      color: const Color(0xF0111111),
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'AS MITRA CHECKOUT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _LineList(session: session, lines: transaction.lines),
              const Divider(color: Colors.white24),
              _MoneyRow(
                label: 'TOTAL',
                amount: transaction.total,
                valueKey: const Key('checkout-total'),
              ),
              if (paying) ...[
                const SizedBox(height: 8),
                const Text(
                  'CASH RECEIVED',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final amount in const [100, 200, 500])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: FilledButton(
                            key: Key('checkout-cash-$amount'),
                            onPressed: () => session.tender(amount),
                            child: Text('$amount'),
                          ),
                        ),
                      ),
                  ],
                ),
                if (session.showInsufficientCash) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'INSUFFICIENT CASH',
                    key: Key('checkout-insufficient'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFFFB4A8), fontSize: 14),
                  ),
                ],
                if (transaction.isPaid) ...[
                  const SizedBox(height: 8),
                  _MoneyRow(label: 'CASH', amount: transaction.cashReceived!),
                  _MoneyRow(
                    label: 'CHANGE',
                    amount: transaction.change ?? 0,
                    valueKey: const Key('checkout-change'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('checkout-complete'),
                    onPressed: session.finish,
                    child: const Text('Complete'),
                  ),
                ],
              ],
              if (!paying) ...[
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('checkout-scan'),
                  onPressed: session.scanHeldItem,
                  child: const Text('Scan'),
                ),
                const SizedBox(height: 6),
                FilledButton(
                  key: const Key('checkout-pay'),
                  onPressed: session.requestPayment,
                  child: const Text('Pay'),
                ),
              ],
              const SizedBox(height: 6),
              TextButton(
                key: const Key('checkout-cancel'),
                onPressed: session.cancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineList extends StatelessWidget {
  const _LineList({required this.session, required this.lines});

  final CheckoutSession session;
  final List<SaleLine> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No items yet',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 120),
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${session.catalog.lookup(line.productId)?.marathiName ?? line.productId}'
                      ' × ${line.quantity}',
                      key: Key('checkout-line-${line.productId}'),
                      style: const TextStyle(
                        fontFamily: 'Nirmala UI',
                        fontFamilyFallback: [
                          'Segoe UI',
                          'Noto Sans Devanagari',
                          'Mangal',
                        ],
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    temporaryPriceLabel(line.lineTotal),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.amount, this.valueKey});

  final String label;
  final int amount;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            temporaryPriceLabel(amount),
            key: valueKey,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SaleNotice extends StatefulWidget {
  const _SaleNotice({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<_SaleNotice> createState() => _SaleNoticeState();
}

class _SaleNoticeState extends State<_SaleNotice> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('sale-complete-notice'),
      color: const Color(0xF0111111),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(
          widget.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
