package net.zsemper.ftao.parts;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.awt.Dimension;

public final class Constants {
    public static final Logger LOG = LogManager.getLogger("FTaO");

    public static final Object[] NO_PARAMS = new Object[0];

    public static final int HEIGHT = 30;

    public static final Dimension SPINNER_DIMENSION = new Dimension(90, HEIGHT);

    public static final String WIKI_URL = "https://zsemper.github.io/plugin/";
}
