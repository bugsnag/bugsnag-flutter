package com.bugsnag.flutter;

import androidx.annotation.Nullable;

import com.bugsnag.android.BreadcrumbType;
import com.bugsnag.android.Telemetry;

import org.json.JSONArray;

import java.util.Collections;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Utility class containing mappings between Dart <-> Android enums
 */
class EnumHelper {
    private static final Map<String, BreadcrumbType> dartBreadcrumbTypes = new HashMap<>();
    private static final Map<String, Telemetry> dartTelemetry = new HashMap<>();

    static {
        dartBreadcrumbTypes.put("navigation", BreadcrumbType.NAVIGATION);
        dartBreadcrumbTypes.put("request", BreadcrumbType.REQUEST);
        dartBreadcrumbTypes.put("process", BreadcrumbType.PROCESS);
        dartBreadcrumbTypes.put("log", BreadcrumbType.LOG);
        dartBreadcrumbTypes.put("user", BreadcrumbType.USER);
        dartBreadcrumbTypes.put("state", BreadcrumbType.STATE);
        dartBreadcrumbTypes.put("error", BreadcrumbType.ERROR);
        dartBreadcrumbTypes.put("manual", BreadcrumbType.MANUAL);

        dartTelemetry.put("internalErrors", Telemetry.INTERNAL_ERRORS);
        dartTelemetry.put("usage", Telemetry.USAGE);
    }

    private EnumHelper() {
    }

    static Set<BreadcrumbType> unwrapBreadcrumbTypes(@Nullable JSONArray breadcrumbTypes) {
        if (breadcrumbTypes == null) {
            return Collections.emptySet();
        }

        Set<BreadcrumbType> set = EnumSet.noneOf(BreadcrumbType.class);

        int enabledTypeCount = breadcrumbTypes.length();
        for (int index = 0; index < enabledTypeCount; index++) {
            set.add(dartBreadcrumbTypes.get(breadcrumbTypes.optString(index)));
        }

        return set;
    }

    static Set<Telemetry> unwrapTelemetry(@Nullable JSONArray telemetry) {
        if (telemetry == null) {
            return Collections.emptySet();
        }

        Set<Telemetry> set = EnumSet.noneOf(Telemetry.class);

        int count = telemetry.length();
        for (int i = 0; i < count; i++) {
            set.add(dartTelemetry.get(telemetry.optString(i)));
        }

        return set;
    }
}
