package me.timeto.shared.vm

import kotlinx.coroutines.flow.*
import me.timeto.shared.DI
import me.timeto.shared.db.ActivityModel
import me.timeto.shared.onEachExIn
import me.timeto.shared.textFeatures
import me.timeto.shared.db.ActivityModel__Data.TimerHints.TimerHintUI

class ActivitiesTimerSheetVM(
    private val timerContext: ActivityTimerSheetVM.TimerContext?,
) : __VM<ActivitiesTimerSheetVM.State>() {

    companion object {

        private fun prepActivitiesUI(
            timerContext: ActivityTimerSheetVM.TimerContext?,
            sortedActivities: List<ActivityModel>,
        ): List<ActivityUI> = sortedActivities.map { activity ->

            val timerHints = activity.getData().timer_hints.getTimerHintsUI(
                historyLimit = 3,
                customLimit = 6,
                onSelect = { hintUI ->
                    ActivityTimerSheetVM.startIntervalByContext(timerContext, activity, hintUI.seconds)
                }
            )

            ActivityUI(
                activity = activity,
                timerHints = timerHints
            )
        }
    }

    class ActivityUI(
        val activity: ActivityModel,
        val timerHints: List<TimerHintUI>,
    ) {
        val listText = activity.name.textFeatures().textUi()
        val isActive = DI.lastInterval.activity_id == activity.id
    }

    data class State(
        val allActivities: List<ActivityUI>,
    )

    override val state = MutableStateFlow(
        State(
            allActivities = prepActivitiesUI(timerContext, DI.activitiesSorted),
        )
    )

    override fun onAppear() {
        val scope = scopeVM()
        ActivityModel.getAscSortedFlow().onEachExIn(scope) { activities ->
            state.update {
                it.copy(allActivities = prepActivitiesUI(timerContext, activities))
            }
        }
    }
}
