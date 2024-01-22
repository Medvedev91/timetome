package me.timeto.shared.vm.ui

import me.timeto.shared.TextFeatures
import me.timeto.shared.db.TaskFolderDb
import me.timeto.shared.db.TaskModel
import me.timeto.shared.textFeatures

fun List<TaskModel>.sortedByFolder(
    folder: TaskFolderDb,
): List<TaskModel> {
    if (!folder.isToday)
        return this.sortedByDescending { it.id }

    return this
        .asSequence()
        .map { Pair(it, it.text.textFeatures()) }
        .groupBy { (task, features) ->
            features.fromRepeating?.day
            ?: features.fromEvent?.unixTime?.localDay
            ?: task.unixTime().localDay
        }
        .toList()
        .sortedByDescending { it.first }
        .map {
            it.second.sortedWith(
                compareBy<Pair<TaskModel, TextFeatures>> { (_, features) ->
                    features.fromEvent?.unixTime?.time
                    ?: features.fromRepeating?.time
                    ?: 0
                }
                    .thenBy { it.first.id }
            )
                .map { it.first }
        }
        .flatten()
        .toList()
}
