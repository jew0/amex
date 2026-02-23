import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

void main() {
  runApp(const MaterialApp(
    home: MainNavigation(),
    debugShowCheckedModeBanner: false,
  ));
}

// --- 1. GESTION DES DONNÉES (ÉTAT GLOBAL) ---
class AppData extends ChangeNotifier {
  String userName = "Bastien D.";
  String revTag = "bastien_d";
  double balanceCHF = 150.0;
  
  List<Map<String, dynamic>> history = [
    {"title": "CHF → BTC", "subtitle": "11 févr., 01:13", "amount": -20.0, "icon": Icons.currency_bitcoin, "color": Colors.orange},
    {"title": "Argent ajouté via Apple Pay", "subtitle": "10 févr., 23:29", "amount": 20.0, "icon": Icons.apple, "color": Colors.white},
  ];

  void updateProfile(String newName, String newTag) {
    userName = newName;
    revTag = newTag;
    notifyListeners();
  }

  void addMoney(double amount) {
    balanceCHF += amount;
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
    if (balanceCHF >= amount) {
      balanceCHF -= amount;
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
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white30,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Investir'),
                BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: 'Virements'),
                BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'Cryptos'),
                BottomNavigationBarItem(icon: Icon(Icons.hexagon_outlined), label: 'RevPoints'),
              ],
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
              colors: [Color(0xFF2C3E50), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.45],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 30),
                const Text("Personnel • CHF", style: TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 8),
                Text("${appState.balanceCHF.toInt()} Fr", style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 15),
                _buildCapsule("Comptes et Portefeuilles"),
                const SizedBox(height: 35),
                _buildActionButtons(context),
                const SizedBox(height: 35),
                Expanded(child: _buildTransactionList()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF708CFE),
              child: Text(appState.userName.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
              child: const Row(
                children: [
                  SizedBox(width: 15),
                  Icon(Icons.search, color: Colors.white54, size: 20),
                  SizedBox(width: 10),
                  Text("Rechercher", style: TextStyle(color: Colors.white54, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Icon(Icons.credit_card, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _actionItem(Icons.add, "Ajouter de\nl'argent", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMoneyPage()))),
            _actionItem(Icons.sync_alt, "Déplacer", () {}),
            _actionItem(Icons.account_balance, "Informations", () {}),
            _actionItem(Icons.more_horiz, "Plus", () {}),
          ],
        ),
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 58, height: 58,
              decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF121212), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        itemCount: appState.history.length,
        itemBuilder: (context, i) {
          final tx = appState.history[i];
          return ListTile(
            contentPadding: const EdgeInsets.only(bottom: 12),
            leading: CircleAvatar(backgroundColor: tx['color'].withOpacity(0.1), child: Icon(tx['icon'], color: tx['color'], size: 20)),
            title: Text(tx['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(tx['subtitle'], style: const TextStyle(color: Colors.white38, fontSize: 13)),
            trailing: Text("${tx['amount'] > 0 ? '+' : ''}${tx['amount']} Fr", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          );
        },
      ),
    );
  }

  Widget _buildCapsule(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
      body: SafeArea(
        child: Column(
          children: [
            _buildTransferHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildAddContactsCard(),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: appState,
                builder: (context, _) {
                  // On filtre l'historique pour n'afficher que les débits dans "Récent"
                  final recentTransfers = appState.history.where((tx) => tx['amount'] < 0).toList();
                  
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const Text("Récent", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 15),
                      if (recentTransfers.isEmpty)
                         const Center(child: Text("Aucun virement récent", style: TextStyle(color: Colors.white24)))
                      else
                        ...recentTransfers.map((tx) => _buildRecentItem(tx['title'].replaceAll("Virement vers ", ""), tx['subtitle'], "${tx['amount']} Fr")),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Color(0xFF708CFE), child: Icon(Icons.camera_alt, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [SizedBox(width: 15), Icon(Icons.search, color: Colors.white54, size: 20), SizedBox(width: 10), Text("Rechercher", style: TextStyle(color: Colors.white54))]),
            ),
          ),
          const SizedBox(width: 15),
          const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () => _showIbanOptions(context),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C1F2E), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.contacts, color: Colors.white)),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ajouter vos contacts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 5),
                    Text("Envoyez de l'argent instantanément à vos amis sur Revolut.", style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: const StadiumBorder()), child: const Text("Continuer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String name, String sub, String trailing) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: const Color(0xFF708CFE), child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: Colors.white))),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: Text(trailing, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  void _showIbanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1F2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Envoyer de l'argent", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blueAccent),
              title: const Text("Envoyer vers un IBAN", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Virement bancaire classique", style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SendIbanPage()));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// --- 5. NOUVELLE PAGE : SAISIE DU VIREMENT ---
class SendIbanPage extends StatefulWidget {
  const SendIbanPage({super.key});
  @override
  State<SendIbanPage> createState() => _SendIbanPageState();
}

class _SendIbanPageState extends State<SendIbanPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text("Virement IBAN")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Iban du bénéficiaire", labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Montant (CHF)", labelStyle: TextStyle(color: Colors.white54)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (_nameController.text.isNotEmpty && amount > 0) {
                    appState.sendMoney(_nameController.text, amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Confirmer le virement", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. AUTRES PAGES ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: appState.userName);
    _tagController = TextEditingController(text: appState.revTag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: () {
              appState.updateProfile(_nameController.text, _tagController.text);
              Navigator.pop(context);
            },
            child: const Text("Enregistrer", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFF708CFE),
              child: Text(appState.userName.substring(0, 1), style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 30),
          const Text("INFORMATIONS", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildEditField("Nom", _nameController),
          _buildEditField("Revtag", _tagController, prefix: "@"),
          const SizedBox(height: 30),
          _settingsTile(Icons.security, "Sécurité", "PIN, Biométrie"),
          _settingsTile(Icons.notifications, "Notifications", "Alertes de compte"),
          const SizedBox(height: 40),
          const Text("DÉCONNEXION", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {String prefix = ""}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white38), border: InputBorder.none, prefixText: prefix, prefixStyle: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }
}

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});
  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  String displayAmount = "0";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Column(
        children: [
          const Text("Montant à ajouter", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          Text("$displayAmount Fr", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          _buildNumericPad(),
          Padding(
            padding: const EdgeInsets.all(25),
            child: SizedBox(
              width: double.infinity, height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  if (displayAmount != "0") {
                    appState.addMoney(double.parse(displayAmount));
                    Navigator.pop(context);
                  }
                },
                child: const Text("Payer avec Apple Pay", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNumericPad() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.6),
      itemCount: 12,
      itemBuilder: (context, i) {
        if (i < 9) return _key("${i + 1}");
        if (i == 9) return const SizedBox();
        if (i == 10) return _key("0");
        return IconButton(onPressed: () => setState(() => displayAmount = "0"), icon: const Icon(Icons.backspace_outlined, color: Colors.white));
      },
    );
  }

  Widget _key(String label) => TextButton(onPressed: () => setState(() => displayAmount = displayAmount == "0" ? label : displayAmount + label), child: Text(label, style: const TextStyle(fontSize: 28, color: Colors.white)));
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: Icon(icon, size: 100, color: Colors.white12)));
}