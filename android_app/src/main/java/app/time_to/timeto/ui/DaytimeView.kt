package app.time_to.timeto.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.time_to.timeto.R
import app.time_to.timeto.toColor
import timeto.shared.vm.ui.DaytimeUI

@Composable
fun DaytimeView(
    daytimeUI: DaytimeUI,
    modifier: Modifier,
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
    ) {

        Row(
            modifier = Modifier
                .clip(MySquircleShape(len = 50f))
                .background(daytimeUI.color.toColor())
                .padding(horizontal = 4.dp, vertical = 2.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {

            Icon(
                painterResource(
                    id = when (daytimeUI.daytimeIcon) {
                        DaytimeUI.DaytimeIcon.clock -> R.drawable.sf_clock_medium_medium
                        DaytimeUI.DaytimeIcon.alarm -> R.drawable.sf_alarm_fill_medium_medium
                    }
                ),
                contentDescription = "Daytime",
                modifier = Modifier
                    .size(20.dp, 20.dp)
                    .padding(3.dp),
                tint = c.white
            )

            Text(
                daytimeUI.daytimeText,
                modifier = Modifier.padding(start = 1.dp, end = 3.dp),
                fontSize = 13.sp,
                color = c.white,
            )
        }

        val timeLeftText = daytimeUI.timeLeftText
        if (timeLeftText != null) {
            Text(
                timeLeftText,
                modifier = Modifier.padding(start = 8.dp),
                fontSize = 14.sp,
                color = daytimeUI.color.toColor(),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
