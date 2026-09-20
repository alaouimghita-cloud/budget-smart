import 'package:flutter/material.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> {
  String _currentLang = 'AR';

  void _toggleLanguage(String lang) {
    setState(() {
      _currentLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميزانيتي الذكية',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(
        lang: _currentLang,
        onLangChange: _toggleLanguage,
      ),
    );
  }
}

// ----------------- النماذج (Data Models) -----------------

class IncomeItem {
  String id;
  String type;
  double amount;
  DateTime date;
  String note;

  IncomeItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.note = '',
  });
}

class ExpenseItem {
  String id;
  String category;
  double amount;
  DateTime date;
  String note;

  ExpenseItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
}

class SavingsTransaction {
  String id;
  double amount;
  DateTime date;

  SavingsTransaction({
    required this.id,
    required this.amount,
    required this.date,
  });
}

class SavingsGoal {
  String id;
  String name;
  double targetAmount;
  DateTime targetDate;
  IconData icon;
  List<SavingsTransaction> deposits;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    this.icon = Icons.savings,
    List<SavingsTransaction>? deposits,
  }) : deposits = deposits ?? [];

  double get currentAmount => deposits.fold(0, (sum, d) => sum + d.amount);
  double get remaining => targetAmount - currentAmount;
}

class DebtPayment {
  String id;
  double amount;
  DateTime date;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
  });
}

class DebtItem {
  String id;
  String name;
  double totalAmount;
  DateTime dueDate;
  List<DebtPayment> payments;

  DebtItem({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.dueDate,
    List<DebtPayment>? payments,
  }) : payments = payments ?? [];

  double get totalPaid => payments.fold(0, (sum, p) => sum + p.amount);
  double get remainingAmount => totalAmount - totalPaid;
  bool get isPaidOff => remainingAmount <= 0;
}

// ----------------- الشاشة الرئيسية -----------------

class HomeScreen extends StatefulWidget {
  final String lang;
  final Function(String) onLangChange;

  const HomeScreen({super.key, required this.lang, required this.onLangChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDashboardDate = DateTime.now();

  List<IncomeItem> incomes = [];
  List<ExpenseItem> expenses = [];

  List<String> incomeTypesAr = ['راتب شهري', 'مكافأة', 'هدية'];
  List<String> incomeTypesFr = ['Salaire', 'Prime', 'Cadeau'];

  List<String> expenseCategoriesAr = ['الأكل', 'الدراسة', 'الرياضة', 'السكن', 'الفواتير'];
  List<String> expenseCategoriesFr = ['Nourriture', 'Études', 'Sport', 'Logement', 'Factures'];

  List<SavingsGoal> savingsGoals = [];
  List<DebtItem> debts = [];

  bool get isAr => widget.lang == 'AR';

  bool _isSameMonthAndYear(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month;
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  double get selectedMonthRawIncome => incomes
      .where((item) => _isSameMonthAndYear(item.date, selectedDashboardDate))
      .fold(0, (sum, item) => sum + item.amount);

  double get selectedMonthExpenses => expenses
      .where((item) => _isSameMonthAndYear(item.date, selectedDashboardDate))
      .fold(0, (sum, item) => sum + item.amount);

  double get selectedMonthSavingsDeposits {
    double total = 0;
    for (var goal in savingsGoals) {
      for (var deposit in goal.deposits) {
        if (_isSameMonthAndYear(deposit.date, selectedDashboardDate)) {
          total += deposit.amount;
        }
      }
    }
    return total;
  }

  double get selectedMonthDebtsPaid {
    double total = 0;
    for (var debt in debts) {
      for (var payment in debt.payments) {
        if (_isSameMonthAndYear(payment.date, selectedDashboardDate)) {
          total += payment.amount;
        }
      }
    }
    return total;
  }

  double get netBalance => selectedMonthRawIncome - (selectedMonthExpenses + selectedMonthSavingsDeposits + selectedMonthDebtsPaid);

  double get totalAccumulatedSavings {
    return savingsGoals.fold(0, (sum, goal) => sum + goal.currentAmount);
  }

  double get totalRemainingDebts {
    return debts.fold(0, (sum, debt) => sum + debt.remainingAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF4A00E0),
          title: Text(
            isAr ? 'ميزانيتي الذكية 💎' : 'Mon Budget Smart 💎',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.language_rounded, color: Colors.white),
                onSelected: widget.onLangChange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'AR', child: Text('العربية 🇲🇦', style: TextStyle(fontWeight: FontWeight.bold))),
                  const PopupMenuItem(value: 'FR', child: Text('Français 🇫🇷', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // الهيدر المتدرج الحديث
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x334A00E0),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDashboardDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDashboardDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              '${isAr ? "التاريخ" : "Date"}: ${_formatDate(selectedDashboardDate)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      isAr 
                          ? 'الرصيد الصافي المتبقي لشهر (${_formatDate(selectedDashboardDate)})' 
                          : 'Solde Net Restant du (${_formatDate(selectedDashboardDate)})',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: netBalance >= 0 
                            ? [const Color(0xFF00FF87), const Color(0xFF60EFFF)]
                            : [const Color(0xFFFF5252), const Color(0xFFFF7A00)],
                      ).createShader(bounds),
                      child: Text(
                        '${netBalance.toStringAsFixed(2)} DH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // بطاقات الأقسام
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildModernCard(
                      title: isAr ? 'المدخول الصافي المتبقي' : 'Revenu Net Restant',
                      subtitle: isAr 
                          ? 'تاريخ اليوم: ${_formatDate(selectedDashboardDate)}\nالخام: ${selectedMonthRawIncome.toStringAsFixed(2)} DH' 
                          : 'Date: ${_formatDate(selectedDashboardDate)}\nBrut: ${selectedMonthRawIncome.toStringAsFixed(2)} DH',
                      amount: netBalance,
                      badgeColor: netBalance >= 0 ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                      icon: Icons.account_balance_rounded,
                      accentGradient: const [Color(0xFF00B894), Color(0xFF00CEC9)],
                      onTap: () => _openIncomeHistory(),
                    ),
                    _buildModernCard(
                      title: isAr ? 'المصروف الشهري' : 'Dépenses Mensuelles',
                      subtitle: isAr ? 'بتاريخ ${_formatDate(selectedDashboardDate)}' : 'Date ${_formatDate(selectedDashboardDate)}',
                      amount: selectedMonthExpenses,
                      badgeColor: const Color(0xFFFF7675),
                      icon: Icons.shopping_bag_rounded,
                      accentGradient: const [Color(0xFFFF7675), Color(0xFFD63031)],
                      onTap: () => _openExpensesHistory(),
                    ),
                    _buildModernCard(
                      title: isAr ? 'صندوق الادخار التراكمي' : 'Épargne Cumulée',
                      subtitle: isAr ? 'المقتطع فـ ${selectedDashboardDate.month}/${selectedDashboardDate.year}: ${selectedMonthSavingsDeposits.toStringAsFixed(2)} DH' : 'Déposé ce mois: ${selectedMonthSavingsDeposits.toStringAsFixed(2)} DH',
                      amount: totalAccumulatedSavings,
                      badgeColor: const Color(0xFF0984E3),
                      icon: Icons.savings_rounded,
                      accentGradient: const [Color(0xFF0984E3), Color(0xFF74B9FF)],
                      onTap: () => _openSavingsSection(),
                    ),
                    _buildModernCard(
                      title: isAr ? 'إجمالي الديون المتبقية' : 'Dettes Restantes Total',
                      subtitle: isAr ? 'المسدد فـ ${selectedDashboardDate.month}/${selectedDashboardDate.year}: ${selectedMonthDebtsPaid.toStringAsFixed(2)} DH' : 'Payé ce mois: ${selectedMonthDebtsPaid.toStringAsFixed(2)} DH',
                      amount: totalRemainingDebts,
                      badgeColor: const Color(0xFF6C5CE7),
                      icon: Icons.credit_card_rounded,
                      accentGradient: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      onTap: () => _openDebtsSection(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required String subtitle,
    required double amount,
    required Color badgeColor,
    required IconData icon,
    required List<Color> accentGradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: accentGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: accentGradient.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3436)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${amount.toStringAsFixed(2)}\nDH',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: badgeColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- 1. قسم المدخول -----------------
  void _openIncomeHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final monthIncomes = incomes.where((item) => _isSameMonthAndYear(item.date, selectedDashboardDate)).toList();
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'مدخول شهر ${selectedDashboardDate.month}/${selectedDashboardDate.year} 📑' : 'Revenus du Mois 📑', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B894),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => _showIncomeForm(setModalState: setModalState),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text(isAr ? 'إضافة' : 'Ajouter', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    height: 350,
                    child: monthIncomes.isEmpty
                        ? Center(child: Text(isAr ? 'لا يوجد مدخول مسجل' : 'Aucun revenu enregistré', style: const TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: monthIncomes.length,
                            itemBuilder: (context, index) {
                              final item = monthIncomes[index];
                              return Card(
                                elevation: 0,
                                color: const Color(0xFFF8F9FD),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  title: Text('${item.type} - ${item.amount} DH', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${isAr ? "التاريخ" : "Date"}: ${_formatDate(item.date)}${item.note.isNotEmpty ? " | ${item.note}" : ""}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                        onPressed: () => _showIncomeForm(itemToEdit: item, setModalState: setModalState),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() => incomes.removeWhere((e) => e.id == item.id));
                                          setModalState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showIncomeForm({IncomeItem? itemToEdit, required StateSetter setModalState}) {
    DateTime incomeDate = itemToEdit?.date ?? selectedDashboardDate;
    final amountController = TextEditingController(text: itemToEdit != null ? itemToEdit.amount.toString() : '');
    final noteController = TextEditingController(text: itemToEdit?.note ?? '');
    List<String> currentTypeList = isAr ? incomeTypesAr : incomeTypesFr;
    String selectedType = itemToEdit != null ? itemToEdit.type : currentTypeList.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(itemToEdit == null ? (isAr ? 'إضافة مدخول' : 'Ajouter Revenu') : (isAr ? 'تعديل/تصحيح مدخول' : 'Modifier Revenu'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: incomeDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setDialogState(() => incomeDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${isAr ? "التاريخ" : "Date"}: ${_formatDate(incomeDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF6C5CE7)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'المبلغ بالدرهم' : 'Montant DH',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: isAr ? 'ملاحظة' : 'Remarque',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: currentTypeList.contains(selectedType) ? selectedType : null,
                          hint: Text(selectedType),
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: currentTypeList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setDialogState(() => selectedType = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF6C5CE7), size: 32),
                        onPressed: () {
                          _showAddNewDialog(isAr ? 'إضافة نوع جديد' : 'Nouveau type', (val) {
                            setState(() {
                              isAr ? incomeTypesAr.add(val) : incomeTypesFr.add(val);
                            });
                            setDialogState(() => selectedType = val);
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      double amt = double.tryParse(amountController.text) ?? 0.0;
                      setState(() {
                        if (itemToEdit == null) {
                          incomes.add(IncomeItem(id: DateTime.now().toString(), type: selectedType, amount: amt, date: incomeDate, note: noteController.text));
                        } else {
                          itemToEdit.type = selectedType;
                          itemToEdit.amount = amt;
                          itemToEdit.date = incomeDate;
                          itemToEdit.note = noteController.text;
                        }
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isAr ? 'حفظ / تصحيح' : 'Sauvegarder', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ----------------- 2. قسم المصاريف -----------------
  void _openExpensesHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final monthExpenses = expenses.where((item) => _isSameMonthAndYear(item.date, selectedDashboardDate)).toList();
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'مصاريف شهر ${selectedDashboardDate.month}/${selectedDashboardDate.year} 🛒' : 'Dépenses du Mois 🛒', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7675),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => _showExpenseForm(setModalState: setModalState),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text(isAr ? 'إضافة' : 'Ajouter', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    height: 350,
                    child: monthExpenses.isEmpty
                        ? Center(child: Text(isAr ? 'لا يوجد مصاريف مسجلة' : 'Aucune dépense', style: const TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: monthExpenses.length,
                            itemBuilder: (context, index) {
                              final item = monthExpenses[index];
                              return Card(
                                elevation: 0,
                                color: const Color(0xFFF8F9FD),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  title: Text('${item.category} - ${item.amount} DH', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${isAr ? "التاريخ" : "Date"}: ${_formatDate(item.date)}${item.note.isNotEmpty ? " | ${item.note}" : ""}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                        onPressed: () => _showExpenseForm(itemToEdit: item, setModalState: setModalState),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() => expenses.removeWhere((e) => e.id == item.id));
                                          setModalState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExpenseForm({ExpenseItem? itemToEdit, required StateSetter setModalState}) {
    DateTime expenseDate = itemToEdit?.date ?? selectedDashboardDate;
    final amountController = TextEditingController(text: itemToEdit != null ? itemToEdit.amount.toString() : '');
    final noteController = TextEditingController(text: itemToEdit?.note ?? '');
    List<String> currentCategories = isAr ? expenseCategoriesAr : expenseCategoriesFr;
    String selectedCategory = itemToEdit != null ? itemToEdit.category : currentCategories.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(itemToEdit == null ? (isAr ? 'تسجيل مصروف' : 'Ajouter Dépense') : (isAr ? 'تعديل/تصحيح مصروف' : 'Modifier Dépense'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: expenseDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setDialogState(() => expenseDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${isAr ? "التاريخ" : "Date"}: ${_formatDate(expenseDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFFF7675)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'المبلغ بالدرهم' : 'Montant DH',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: isAr ? 'ملاحظة' : 'Remarque',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: currentCategories.contains(selectedCategory) ? selectedCategory : null,
                          hint: Text(selectedCategory),
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          items: currentCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setDialogState(() => selectedCategory = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_rounded, color: Color(0xFFFF7675), size: 32),
                        onPressed: () {
                          _showAddNewDialog(isAr ? 'إضافة خانة جديدة' : 'Nouvelle catégorie', (val) {
                            setState(() {
                              isAr ? expenseCategoriesAr.add(val) : expenseCategoriesFr.add(val);
                            });
                            setDialogState(() => selectedCategory = val);
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7675),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      double amt = double.tryParse(amountController.text) ?? 0.0;
                      setState(() {
                        if (itemToEdit == null) {
                          expenses.add(ExpenseItem(id: DateTime.now().toString(), category: selectedCategory, amount: amt, date: expenseDate, note: noteController.text));
                        } else {
                          itemToEdit.category = selectedCategory;
                          itemToEdit.amount = amt;
                          itemToEdit.date = expenseDate;
                          itemToEdit.note = noteController.text;
                        }
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isAr ? 'حفظ / تصحيح' : 'Sauvegarder', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ----------------- 3. قسم الادخار والتعديل عليه -----------------
  void _openSavingsSection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'خانات أهداف الادخار 🎯' : 'Champs d\'Épargne 🎯', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0984E3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => _createOrEditSavingsGoalDialog(setModalState: setModalState),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text(isAr ? 'خانة جديدة' : 'Nouveau Goal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    height: 420,
                    child: savingsGoals.isEmpty
                        ? Center(child: Text(isAr ? 'لا توجد خانات ادخار حالياً' : 'Aucun objectif défini', style: const TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: savingsGoals.length,
                            itemBuilder: (context, index) {
                              final goal = savingsGoals[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FD),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF0984E3).withOpacity(0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(0xFF0984E3),
                                          child: Icon(goal.icon, color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            goal.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                                          tooltip: isAr ? 'تعديل المعطيات' : 'Modifier',
                                          onPressed: () => _createOrEditSavingsGoalDialog(goalToEdit: goal, setModalState: setModalState),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0984E3), size: 22),
                                          tooltip: isAr ? 'إيداع مبلغ' : 'Déposer',
                                          onPressed: () => _depositToSavings(goal, setModalState),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.history_rounded, color: Colors.purple, size: 20),
                                          tooltip: isAr ? 'سجل الإيداعات' : 'Historique',
                                          onPressed: () => _showSavingsDepositsHistory(goal, setModalState),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                          onPressed: () {
                                            setState(() => savingsGoals.removeAt(index));
                                            setModalState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${isAr ? "المجموع الكلي المجمع:" : "Total Cumulé:"} ${goal.currentAmount} DH', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B894))),
                                        Text('${isAr ? "الهدف:" : "Objectif:"} ${goal.targetAmount} DH', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${isAr ? "المبلغ الباقي:" : "Reste:"} ${goal.remaining > 0 ? goal.remaining : 0} DH',
                                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                        ),
                                        Text('${isAr ? "تاريخ أقصى أجل:" : "Date Cible:"} ${_formatDate(goal.targetDate)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _createOrEditSavingsGoalDialog({SavingsGoal? goalToEdit, required StateSetter setModalState}) {
    final nameController = TextEditingController(text: goalToEdit?.name ?? '');
    final targetController = TextEditingController(text: goalToEdit != null ? goalToEdit.targetAmount.toString() : '');
    DateTime targetDate = goalToEdit?.targetDate ?? DateTime.now().add(const Duration(days: 90));
    IconData selectedIcon = goalToEdit?.icon ?? Icons.savings;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(goalToEdit == null ? (isAr ? 'إنشاء خانة ادخار جديدة' : 'Créer un Objectif') : (isAr ? 'تصحيح معطيات الادخار' : 'Modifier Objectif'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: isAr ? 'اسم الهدف' : 'Nom de l\'objectif',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'المبلغ المستهدف (DH)' : 'Montant Cible DH',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icons.savings,
                      Icons.directions_car,
                      Icons.home,
                      Icons.flight,
                      Icons.shopping_bag,
                    ].map((icon) {
                      return IconButton(
                        icon: Icon(icon, color: selectedIcon == icon ? const Color(0xFF0984E3) : Colors.grey),
                        onPressed: () => setDialogState(() => selectedIcon = icon),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: targetDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setDialogState(() => targetDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${isAr ? "تاريخ تحقيق الهدف" : "Date Cible"}: ${_formatDate(targetDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0984E3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0984E3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && targetController.text.isNotEmpty) {
                      double targetAmt = double.tryParse(targetController.text) ?? 0.0;
                      setState(() {
                        if (goalToEdit == null) {
                          savingsGoals.add(SavingsGoal(
                            id: DateTime.now().toString(),
                            name: nameController.text,
                            targetAmount: targetAmt,
                            targetDate: targetDate,
                            icon: selectedIcon,
                          ));
                        } else {
                          goalToEdit.name = nameController.text;
                          goalToEdit.targetAmount = targetAmt;
                          goalToEdit.targetDate = targetDate;
                          goalToEdit.icon = selectedIcon;
                        }
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isAr ? 'حفظ / تصحيح' : 'Sauvegarder', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _depositToSavings(SavingsGoal goal, StateSetter setModalState, {SavingsTransaction? depositToEdit}) {
    final amountController = TextEditingController(text: depositToEdit != null ? depositToEdit.amount.toString() : '');
    DateTime depositDate = depositToEdit?.date ?? selectedDashboardDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(depositToEdit == null ? '${isAr ? "إيداع مبلغ فـ" : "Déposer dans"}: ${goal.name}' : isAr ? 'تصحيح الإيداع' : 'Modifier Dépôt', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: depositDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setDialogState(() => depositDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${isAr ? "تاريخ الإيداع" : "Date"}: ${_formatDate(depositDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF0984E3)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'المبلغ المقتطع (DH)' : 'Montant DH',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0984E3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      double amt = double.tryParse(amountController.text) ?? 0.0;
                      setState(() {
                        if (depositToEdit == null) {
                          goal.deposits.add(SavingsTransaction(
                            id: DateTime.now().toString(),
                            amount: amt,
                            date: depositDate,
                          ));
                        } else {
                          depositToEdit.amount = amt;
                          depositToEdit.date = depositDate;
                        }
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isAr ? 'حفظ' : 'Sauvegarder', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showSavingsDepositsHistory(SavingsGoal goal, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('${isAr ? "سجل إيداعات" : "Historique de"}: ${goal.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: goal.deposits.isEmpty
                    ? Center(child: Text(isAr ? 'لا توجد إيداعات مسجلة' : 'Aucun dépôt', style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: goal.deposits.length,
                        itemBuilder: (context, index) {
                          final deposit = goal.deposits[index];
                          return ListTile(
                            leading: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF0984E3)),
                            title: Text('${deposit.amount} DH', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${isAr ? "التاريخ" : "Date"}: ${_formatDate(deposit.date)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _depositToSavings(goal, setModalState, depositToEdit: deposit);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      goal.deposits.removeWhere((d) => d.id == deposit.id);
                                    });
                                    setDialogState(() {});
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إغلاق' : 'Fermer', style: const TextStyle(color: Colors.grey)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ----------------- 4. قسم الديون والتعديل الكامل -----------------
  void _openDebtsSection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'سجل الديون العامة 💳' : 'Gestion des Dettes 💳', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => _showDebtForm(setModalState: setModalState),
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: Text(isAr ? 'دين جديد' : 'Nouvelle Dette', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    height: 380,
                    child: debts.isEmpty
                        ? Center(child: Text(isAr ? 'لا توجد ديون مسجلة' : 'Aucune dette enregistrée', style: const TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: debts.length,
                            itemBuilder: (context, index) {
                              final debt = debts[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 0,
                                color: debt.isPaidOff ? const Color(0xFFE8F8F5) : const Color(0xFFF8F9FD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: debt.isPaidOff ? const Color(0xFF00B894).withOpacity(0.3) : const Color(0xFFFF7675).withOpacity(0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(debt.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: debt.isPaidOff ? const Color(0xFF00B894) : const Color(0xFF2D3436))),
                                              if (debt.isPaidOff)
                                                Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(color: const Color(0xFF00B894), borderRadius: BorderRadius.circular(8)),
                                                  child: Text(isAr ? 'مستوفى بالكامل' : 'Payé', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20),
                                                tooltip: isAr ? 'تعديل المعطيات' : 'Modifier',
                                                onPressed: () => _showDebtForm(debtToEdit: debt, setModalState: setModalState),
                                              ),
                                              if (!debt.isPaidOff)
                                                IconButton(
                                                  icon: const Icon(Icons.payment_rounded, color: Color(0xFF00B894), size: 20),
                                                  tooltip: isAr ? 'تسديد دفعة' : 'Payer',
                                                  onPressed: () => _payDebtDialog(debt, setModalState),
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.history_rounded, color: Colors.purple, size: 20),
                                                tooltip: isAr ? 'سجل الدفعات' : 'Historique',
                                                onPressed: () => _showPaymentHistory(debt, setModalState),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                                onPressed: () {
                                                  setState(() => debts.removeAt(index));
                                                  setModalState(() {});
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${isAr ? "المبلغ الأصلي:" : "Total:"} ${debt.totalAmount} DH', style: const TextStyle(fontSize: 13)),
                                          Text('${isAr ? "المدفوع كلياً:" : "Payé total:"} ${debt.totalPaid} DH', style: const TextStyle(color: Color(0xFF00B894), fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${isAr ? "المتبقي النهائي:" : "Reste total:"} ${debt.remainingAmount > 0 ? debt.remainingAmount : 0} DH',
                                            style: TextStyle(color: debt.isPaidOff ? const Color(0xFF00B894) : const Color(0xFFFF7675), fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text('${isAr ? "آخر أجل:" : "Échéance:"} ${_formatDate(debt.dueDate)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDebtForm({DebtItem? debtToEdit, required StateSetter setModalState}) {
    final nameController = TextEditingController(text: debtToEdit?.name ?? '');
    final amountController = TextEditingController(text: debtToEdit != null ? debtToEdit.totalAmount.toString() : '');
    DateTime dueDate = debtToEdit?.dueDate ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(debtToEdit == null ? (isAr ? 'إضافة دين جديد' : 'Ajouter Dette') : (isAr ? 'تصحيح معطيات الدين' : 'Modifier Dette'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: isAr ? 'الاسم / الجهة' : 'Nom du créancier',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'مبلغ الدين الإجمالي (DH)' : 'Montant total DH',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setDialogState(() => dueDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${isAr ? "آخر أجل للدين" : "Date limite"}: ${_formatDate(dueDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF6C5CE7)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      double totalAmt = double.tryParse(amountController.text) ?? 0.0;
                      setState(() {
                        if (debtToEdit == null) {
                          debts.add(DebtItem(
                            id: DateTime.now().toString(),
                            name: nameController.text,
                            totalAmount: totalAmt,
                            dueDate: dueDate,
                          ));
                        } else {
                          debtToEdit.name = nameController.text;
                          debtToEdit.totalAmount = totalAmt;
                          debtToEdit.dueDate = dueDate;
                        }
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isAr ? 'حفظ / تصحيح' : 'Sauvegarder', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _payDebtDialog(DebtItem debt, StateSetter setModalState, {DebtPayment? paymentToEdit}) {
    final payController = TextEditingController(text: paymentToEdit != null ? paymentToEdit.amount.toString() : '');
    DateTime paymentDate = paymentToEdit?.date ?? selectedDashboardDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(paymentToEdit == null ? '${isAr ? "تسديد دفعة لـ" : "Payer dette de"}: ${debt.name}' : isAr ? 'تصحيح الدفعة' : 'Modifier Paiement', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setDialogState(() => paymentDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${isAr ? "تاريخ الدفعة" : "Date de paiement"}: ${_formatDate(paymentDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF6C5CE7)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: payController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'المبلغ المدفوع (DH)' : 'Montant payé DH',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (payController.text.isNotEmpty) {
                      double amt = double.tryParse(payController.text) ?? 0.0;
                      setState(() {
                        if (paymentToEdit == null) {
                          debt.payments.add(DebtPayment(
                            id: DateTime.now().toString(),
                            amount: amt,
                            date: paymentDate,
                          ));
                        } else {
                          paymentToEdit.amount = amt;
                          paymentToEdit.date = paymentDate;
                        }
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isAr ? 'حفظ' : 'Sauvegarder', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentHistory(DebtItem debt, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('${isAr ? "سجل دفعات" : "Historique de"}: ${debt.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: debt.payments.isEmpty
                    ? Center(child: Text(isAr ? 'لا توجد دفعات مسجلة بعد' : 'Aucun paiement enregistré', style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: debt.payments.length,
                        itemBuilder: (context, index) {
                          final payment = debt.payments[index];
                          return ListTile(
                            leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF00B894)),
                            title: Text('${payment.amount} DH', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${isAr ? "التاريخ" : "Date"}: ${_formatDate(payment.date)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _payDebtDialog(debt, setModalState, paymentToEdit: payment);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      debt.payments.removeWhere((p) => p.id == payment.id);
                                    });
                                    setDialogState(() {});
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إغلاق' : 'Fermer', style: const TextStyle(color: Colors.grey)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showAddNewDialog(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: isAr ? 'الاسم' : 'Nom',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Annuler', style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text(isAr ? 'إضافة' : 'Ajouter', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}
