# Mission Control - Assurance Home Care

Kanban-style task management dashboard for Cal 🦞

## 🌐 Dashboard URL
Once deployed: `https://yss-420.github.io/mission-control-assurance/`

## 👥 Team
- Manav (Admin)
- Stephen
- Alex

## 🚀 Quick Start

### Creating Tasks
1. Go to GitHub repository
2. Edit `data/tasks.json`
3. Add new task following the format:
```json
{
  "id": "MC-002",
  "title": "Task Title",
  "description": "Detailed description for Cal",
  "status": "backlog",
  "priority": "high",
  "subtasks": [...],
  "dod": "Definition of done"
}
```

## Task Status Flow
backlog → in_progress → review → done

**Note:** Moving a task to `in_progress` automatically triggers Cal to start working on it!

## 📝 Task Priority Levels
- **critical**: Drop everything, work on this
- **high**: Important, work on soon
- **medium**: Normal priority
- **low**: When you have time

## 🔄 How It Works
1. You create/edit tasks in `data/tasks.json`
2. Commit and push to GitHub
3. GitHub Pages updates the dashboard
4. Webhook notifies Cal when tasks change
5. Cal executes tasks moved to `in_progress`
6. Cal updates task status when done

## 📊 Example Tasks
See `data/tasks.json` for the welcome task example.

## 🔧 Commands
From the workspace, Cal can use:
```bash
# Check task status
mc-update.sh status

# Start a task
mc-update.sh start MC-001

# Mark subtask complete
mc-update.sh subtask MC-001 sub_001

# Complete task
mc-update.sh complete MC-001

# Push updates
mc-update.sh push "Progress update"
```

## 🔗 Links
- Dashboard: (GitHub Pages URL after setup)
- Repository: https://github.com/yss-420/mission-control-assurance

---
Mission Control v1.0.0 - Keeping Assurance Home Care organized
