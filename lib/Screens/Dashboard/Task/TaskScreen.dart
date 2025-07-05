// Task Management Screen
import 'package:flutter/material.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.yellow.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Task Overview Cards
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildTaskOverviewCard(
                    'Total Tasks',
                    '24',
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTaskOverviewCard(
                    'Completed',
                    '18',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTaskOverviewCard(
                    'Pending',
                    '6',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.yellow.shade400,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Overdue'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('all'),
                _buildTaskList('active'),
                _buildTaskList('completed'),
                _buildTaskList('overdue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskOverviewCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(String type) {
    final List<Map<String, dynamic>> tasks = _getTasksByType(type);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: task['priority_color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['priority'],
                      style: TextStyle(
                        color: task['priority_color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: task['status_color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['status'],
                      style: TextStyle(
                        color: task['status_color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                task['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    task['due_date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.yellow.shade300,
                    child: Text(
                      task['assignee'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getTasksByType(String type) {
    final allTasks = [
      {
        'title': 'Complete Mobile App Design',
        'description': 'Finish the UI/UX design for the mobile application',
        'priority': 'High',
        'priority_color': Colors.red,
        'status': 'In Progress',
        'status_color': Colors.blue,
        'due_date': 'Dec 25, 2024',
        'assignee': 'JD',
      },
      {
        'title': 'API Integration',
        'description': 'Integrate REST APIs with the mobile app',
        'priority': 'Medium',
        'priority_color': Colors.orange,
        'status': 'Pending',
        'status_color': Colors.orange,
        'due_date': 'Dec 30, 2024',
        'assignee': 'AS',
      },
      {
        'title': 'Database Setup',
        'description': 'Setup and configure the database schema',
        'priority': 'High',
        'priority_color': Colors.red,
        'status': 'Completed',
        'status_color': Colors.green,
        'due_date': 'Dec 20, 2024',
        'assignee': 'MB',
      },
      {
        'title': 'Testing & QA',
        'description': 'Perform comprehensive testing of all features',
        'priority': 'Low',
        'priority_color': Colors.green,
        'status': 'Overdue',
        'status_color': Colors.red,
        'due_date': 'Dec 15, 2024',
        'assignee': 'SK',
      },
    ];

    switch (type) {
      case 'active':
        return allTasks
            .where((task) => task['status'] == 'In Progress')
            .toList();
      case 'completed':
        return allTasks.where((task) => task['status'] == 'Completed').toList();
      case 'overdue':
        return allTasks.where((task) => task['status'] == 'Overdue').toList();
      default:
        return allTasks;
    }
  }
}
