import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: MaterialApp(
        title: 'AI InnovateHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/explore': (context) => const ExploreScreen(),
          '/upload': (context) => const UploadScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/paper') {
            final paperId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => PaperDetailScreen(paperId: paperId),
            );
          }
          return null;
        },
      ),
    );
  }
}

// Simple data models
data class Paper(
  final String id;
  final String title;
  final List<String> authors;
  final String abstractText;
  final int year;
)

// In-memory repository (replace with real backend/DB later)
class InMemoryRepo {
  final List<Paper> _items = [];

  InMemoryRepo() {
    // seed
    _items.addAll([
      Paper(
        id: 'p1',
        title: 'Contrastive Learning for Vision',
        authors: ['A. Researcher', 'B. Student'],
        abstractText: 'We propose a contrastive learning framework...',
        year: 2024,
      ),
      Paper(
        id: 'p2',
        title: 'Large Language Models for Code',
        authors: ['C. Engineer'],
        abstractText: 'Exploring code generation and evaluation...',
        year: 2025,
      ),
    ]);
  }

  List<Paper> getAll() => _items;

  Paper? findById(String id) => _items.where((paper) => paper.id == id).firstOrNull;

  void add(Paper paper) {
    _items.insert(0, paper);
  }
}

// ViewModel to hold UI state
class MainViewModel extends ChangeNotifier {
  final InMemoryRepo _repo = InMemoryRepo();
  List<Paper> _papers = [];
  bool _isLoading = false;

  List<Paper> get papers => _papers;
  bool get isLoading => _isLoading;

  MainViewModel() {
    loadPapers();
  }

  Future<void> loadPapers() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    _papers = _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Paper? getPaper(String id) => _repo.findById(id);

  void uploadPaper(String title, String authors, String abstractText, int year) {
    final newPaper = Paper(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      authors: authors.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      abstractText: abstractText,
      year: year,
    );
    _repo.add(newPaper);
    loadPapers();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    UploadScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI InnovateHub'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MainViewModel>(context);
    final papers = vm.papers;
    final isLoading = vm.isLoading;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to AI InnovateHub',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const CircularProgressIndicator()
          else ...[
            const Text(
              'Recent papers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PaperList(
                papers: papers,
                onClick: (id) => Navigator.pushNamed(context, '/paper', arguments: id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MainViewModel>(context);
    final papers = vm.papers;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Research',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          const SearchBox(),
          const SizedBox(height: 12),
          Expanded(
            child: PaperList(
              papers: papers,
              onClick: (id) => Navigator.pushNamed(context, '/paper', arguments: id),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Search papers, authors, topics',
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _abstractController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MainViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload new paper / project',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _authorsController,
            decoration: const InputDecoration(
              labelText: 'Authors (comma separated)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _abstractController,
            decoration: const InputDecoration(
              labelText: 'Abstract',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(
              labelText: 'Year',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                final title = _titleController.text.isEmpty ? 'Untitled' : _titleController.text;
                final authors = _authorsController.text;
                final abstractText = _abstractController.text.isEmpty ? '' : _abstractController.text;
                final year = int.tryParse(_yearController.text) ?? 2025;
                vm.uploadPaper(title, authors, abstractText, year);
                setState(() {
                  _message = 'Uploaded successfully';
                });
                _titleController.clear();
                _authorsController.clear();
                _abstractController.clear();
                _yearController.clear();
              },
              child: const Text('Upload'),
            ),
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_message, style: TextStyle(color: Theme.of(context).primaryColor)),
          ],
          const SizedBox(height: 16),
          const Text(
            'Note: file upload / PDF parsing and backend integration are placeholders. Use WorkManager or Retrofit + multipart upload for real uploads.',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorsController.dispose();
    _abstractController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MainViewModel>(context);
    final papers = vm.papers;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle, size: 64),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('HopeMotion Foundation', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Kolhapur, Maharashtra'),
                  Text('hopeMotionFoundation@gmail.com'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'My publications',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PaperList(
              papers: papers,
              onClick: (id) => Navigator.pushNamed(context, '/paper', arguments: id),
            ),
          ),
        ],
      ),
    );
  }
}

class PaperList extends StatelessWidget {
  final List<Paper> papers;
  final void Function(String) onClick;

  const PaperList({super.key, required this.papers, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: InkWell(
            onTap: () => onClick(paper.id),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(paper.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(paper.authors.join(', ')),
                  const SizedBox(height: 6),
                  Text(
                    paper.abstractText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PaperDetailScreen extends StatelessWidget {
  final String paperId;

  const PaperDetailScreen({super.key, required this.paperId});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MainViewModel>(context);
    final paper = vm.getPaper(paperId);

    if (paper == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Paper Detail'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Paper not found'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paper.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Authors: ${paper.authors.join(", ")}'),
            const SizedBox(height: 12),
            const Text(
              'Abstract',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(paper.abstractText),
            const SizedBox(height: 12),
            Text('Year: ${paper.year}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // future: download PDF or view model demo
              },
              child: const Text('Open demo / PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
