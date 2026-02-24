import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

void main() {
  runApp(const MaterialApp(
    home: MainNavigation(),
    debugShowCheckedModeBanner: false,
  ));
}

// --- 1. GESTION DES DONNÉES ---
class AppData extends ChangeNotifier {
  String userName = "User N.";
  String amexTag = "tag"; 
  String email = "user@gmail.com";
  String phone = "+33 07 54 92 51 96";
  String address = "Rue de la Paix 10, 75016 Paris";
  double balanceEURO = 150.00; // Changé en EURO
  
  List<Map<String, dynamic>> history = [
    {"title": "EURO → BTC", "subtitle": "11 févr., 01:13", "amount": -20.0, "icon": Icons.currency_bitcoin, "color": Colors.orange},
    {"title": "Argent ajouté via Apple Pay", "subtitle": "10 févr., 23:29", "amount": 20.0, "icon": Icons.apple, "color": Colors.white},
  ];

  void updateProfile(String name, String tag, String mail, String tel, String addr) {
    userName = name;
    amexTag = tag;
    email = mail;
    phone = tel;
    address = addr;
    notifyListeners();
  }

  void addMoney(double amount) {
    balanceEURO += amount;
    history.insert(0, {
      "title": "Ajout via Apple Pay",
      "subtitle": "Aujourd'hui, ${DateTime.now().hour}:${DateTime.now().minute}",
      "amount": amount,
      "icon": Icons.apple,
      "color": Colors.white
    });
    notifyListeners();
  }

  void sendMoney(String contact, double amount) {
    if (balanceEURO >= amount) {
      balanceEURO -= amount;
      history.insert(0, {
        "title": "Virement vers $contact",
        "subtitle": "Aujourd'hui, ${DateTime.now().hour}:${DateTime.now().minute}",
        "amount": -amount,
        "icon": Icons.account_balance,
        "color": Colors.blueAccent
      });
      notifyListeners();
    }
  }
}

final appState = AppData();

// --- 2. NAVIGATION PRINCIPALE ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeView(),
      const PlaceholderPage(title: "Investir", icon: Icons.show_chart),
      const TransferPage(),
      const PlaceholderPage(title: "Cryptos", icon: Icons.currency_bitcoin),
      const PlaceholderPage(title: "RevPoints", icon: Icons.hexagon_outlined),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  HapticFeedback.lightImpact();
                  setState(() => _currentIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.white.withOpacity(0.4),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: '●'),
                  BottomNavigationBarItem(icon: Icon(Icons.show_chart, size: 28), label: '●'),
                  BottomNavigationBarItem(icon: Icon(Icons.compare_arrows, size: 28), label: '●'),
                  BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin, size: 28), label: '●'),
                  BottomNavigationBarItem(icon: Icon(Icons.hexagon_outlined, size: 28), label: '●'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3. VUE ACCUEIL ---
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 62, 30, 105), Color.fromARGB(255, 37, 32, 67), Color.fromARGB(255, 37, 4, 97)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 20),
                  const Text("PERSONNEL • EURO", style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text("${appState.balanceEURO.toStringAsFixed(2)} €", style: const TextStyle(fontSize: 65, fontWeight: FontWeight.w200, color: Colors.white)),
                  const SizedBox(height: 10),
                  _buildGlassCapsule("Comptes et Portefeuilles"),
                  const SizedBox(height: 40),
                  _buildActionButtons(context),
                  const SizedBox(height: 40),
                  Expanded(child: _buildGlassTransactionList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _glassCircle(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
              child: Text(appState.userName.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _glassContainer(
              height: 45,
              borderRadius: BorderRadius.circular(25),
              child: const Row(
                children: [
                  SizedBox(width: 15),
                  Icon(Icons.search, color: Colors.white54, size: 18),
                  SizedBox(width: 10),
                  Text("Rechercher", style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 15),
          const Icon(Icons.credit_card, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _glassAction(Icons.add, "Ajouter", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMoneyPage()))),
          _glassAction(Icons.sync_alt, "Déplacer", () {}),
          _glassAction(Icons.account_balance, "Détails", () {}),
          _glassAction(Icons.more_horiz, "Plus", () {}),
        ],
      ),
    );
  }

  Widget _glassAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        _glassCircle(
          size: 60,
          child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildGlassTransactionList() {
    return _glassContainer(
      width: double.infinity,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: ListView.builder(
        padding: const EdgeInsets.all(25),
        itemCount: appState.history.length,
        itemBuilder: (context, i) {
          final tx = appState.history[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                _glassCircle(size: 45, opacity: 0.1, child: Icon(tx['icon'], color: tx['color'], size: 20)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(tx['subtitle'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                Text("${tx['amount'] > 0 ? '+' : ''}${tx['amount'].toStringAsFixed(2)} €", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassCapsule(String text) {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// --- 4. PAGE VIREMENTS ---
class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010816),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.15),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTransferHeader(context),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _glassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(30),
                    child: Column(
                      children: [
                        const Icon(Icons.contacts_rounded, color: Colors.blueAccent, size: 40),
                        const SizedBox(height: 15),
                        const Text("Amis sur Amex", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 5),
                        const Text("Envoyez de l'argent instantanément.", style: TextStyle(color: Colors.white38, fontSize: 13), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        _glassButton("Synchroniser", () {}),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) {
                      final recent = appState.history.where((tx) => tx['amount'] < 0).toList();
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const Text("RÉCENTS", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.2)),
                          const SizedBox(height: 15),
                          ...recent.map((tx) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _glassCircle(size: 45, child: const Icon(Icons.person, color: Colors.white)),
                            title: Text(tx['title'].replaceAll("Virement vers ", ""), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(tx['subtitle'], style: const TextStyle(color: Colors.white38)),
                            trailing: Text("${tx['amount']} €", style: const TextStyle(color: Colors.white)),
                          )),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _glassCircle(size: 40, child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20)),
          const SizedBox(width: 15),
          Expanded(child: _glassContainer(height: 40, borderRadius: BorderRadius.circular(20), child: const Center(child: Text("Chercher par @tag", style: TextStyle(color: Colors.white54))))),
          const SizedBox(width: 15),
          GestureDetector(onTap: () => _showIbanOptions(context), child: _glassCircle(size: 40, child: const Icon(Icons.add, color: Colors.white))),
        ],
      ),
    );
  }

  void _showIbanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _glassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            const Text("Transférer", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: _glassCircle(size: 45, child: const Icon(Icons.account_balance, color: Colors.blueAccent)),
              title: const Text("Virement IBAN", style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SendIbanPage())); },
            ),
          ],
        ),
      ),
    );
  }
}

// --- 5. PAGE SAISIE ---
class SendIbanPage extends StatefulWidget {
  const SendIbanPage({super.key});
  @override
  State<SendIbanPage> createState() => _SendIbanPageState();
}

class _SendIbanPageState extends State<SendIbanPage> {
  final _nameC = TextEditingController();
  final _amountC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Nouveau Virement")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _glassTextField("IBAN du bénéficiaire", _nameC),
            const SizedBox(height: 20),
            _glassTextField("Montant EURO", _amountC, type: TextInputType.number),
            const Spacer(),
            _glassButton("Confirmer l'envoi", () {
              final amt = double.tryParse(_amountC.text) ?? 0.0;
              if (_nameC.text.isNotEmpty && amt > 0) {
                appState.sendMoney(_nameC.text, amt);
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _glassTextField(String label, TextEditingController c, {TextInputType type = TextInputType.text}) {
    return _glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        controller: c, keyboardType: type, style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white38), border: InputBorder.none),
      ),
    );
  }
}

// --- 6. RÉGLAGES ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameC;
  late TextEditingController _tagC;
  late TextEditingController _mailC;
  late TextEditingController _phoneC;
  late TextEditingController _addrC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: appState.userName);
    _tagC = TextEditingController(text: appState.amexTag);
    _mailC = TextEditingController(text: appState.email);
    _phoneC = TextEditingController(text: appState.phone);
    _addrC = TextEditingController(text: appState.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent, expandedHeight: 180, pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(child: _glassCircle(size: 80, child: Text(appState.userName[0], style: const TextStyle(fontSize: 30, color: Colors.white)))),
            ),
            actions: [
              TextButton(
                onPressed: () { 
                  appState.updateProfile(_nameC.text, _tagC.text, _mailC.text, _phoneC.text, _addrC.text); 
                  Navigator.pop(context); 
                }, 
                child: const Text("OK", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _glassContainer(
                borderRadius: BorderRadius.circular(25),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    _glassEditField("Nom", _nameC),
                    _glassEditField("AmexTag", _tagC),
                    _glassEditField("Email", _mailC),
                    _glassEditField("Téléphone", _phoneC),
                    _glassEditField("Adresse", _addrC),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _glassEditField(String label, TextEditingController c) {
    return TextField(
      controller: c, 
      style: const TextStyle(color: Colors.white, fontSize: 14), 
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12), 
        border: InputBorder.none, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
      )
    );
  }
}

// --- PAGE AJOUT ARGENT ---
class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});
  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  String amt = "0";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text("AJOUTER", style: TextStyle(color: Colors.white38, letterSpacing: 2)),
            Text("$amt €", style: const TextStyle(fontSize: 70, color: Colors.white, fontWeight: FontWeight.w100)),
            const Spacer(),
            _buildGlassPad(),
            Padding(padding: const EdgeInsets.all(30), child: _glassButton("Apple Pay", () {
              if (amt != "0") { appState.addMoney(double.parse(amt)); Navigator.pop(context); }
            }, color: Colors.white, textColor: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassPad() {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5),
      itemCount: 12, itemBuilder: (context, i) {
        if (i < 9) return _key("${i + 1}");
        if (i == 9) return const SizedBox();
        if (i == 10) return _key("0");
        return IconButton(onPressed: () => setState(() => amt = "0"), icon: const Icon(Icons.backspace, color: Colors.white30));
      }
    );
  }
  Widget _key(String val) => TextButton(onPressed: () => setState(() => amt = amt == "0" ? val : amt + val), child: Text(val, style: const TextStyle(fontSize: 30, color: Colors.white)));
}

class PlaceholderPage extends StatelessWidget {
  final String title; final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: _glassCircle(size: 150, child: Icon(icon, size: 50, color: Colors.white24))));
}

// --- TOOLKIT GLASSMORPHISM ---
Widget _glassContainer({double? width, double? height, EdgeInsets? padding, BorderRadius? borderRadius, required Widget child}) {
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        width: width, height: height, padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: borderRadius,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: child,
      ),
    ),
  );
}

Widget _glassCircle({double size = 50, required Widget child, double opacity = 0.08}) {
  return ClipOval(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Center(child: child),
      ),
    ),
  );
}

Widget _glassButton(String label, VoidCallback onTap, {Color color = Colors.blueAccent, Color textColor = Colors.white}) {
  return GestureDetector(
    onTap: onTap,
    child: _glassContainer(
      width: double.infinity, height: 55,
      borderRadius: BorderRadius.circular(20),
      child: Center(child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))),
    ),
  );
}