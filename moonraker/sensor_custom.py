# Custom Sensor Support
# FLSUN S1 Open Source Edition

from __future__ import annotations

import logging
import pathlib
from ..utils import json_wrapper as jsonw
from .sensor import BaseSensor
from typing import (
    Any,
    DefaultDict,
    Deque,
    Dict,
    List,
    Optional,
    Type,
    TYPE_CHECKING,
    Union,
    Callable
)

if TYPE_CHECKING:
    from ..confighelper import ConfigHelper
    from .sensor import Sensors
    
class JsonFileSensor(BaseSensor):
    def __init__(self, config: ConfigHelper) -> None:
        super().__init__(config=config)
        self.path: pathlib.Path = pathlib.Path(config.get("path"));
        
    def _update_sensor_value(self, eventtime: float) -> None:
        try:
            if self.path.exists:
                jsontext = self.path.read_text(encoding="utf-8")
                if jsontext is not None:
                    try:
                        jsondata: Dict[str, Any] = jsonw.loads(jsontext)
                        for param in self.param_info:
                            try:
                                patharr = param["json_path"].split("/")
                                value = jsondata
                                for key in patharr:
                                  if isinstance(value[key], Dict):
                                    value = value[key]
                                  else:
                                    valueName = key
                                self.last_measurements[param["name"]] = value[valueName]
                            except:
                                self.last_measurements[param["name"]] = -1
                    except:
                        for param in self.param_info:
                            self.last_measurements[param["name"]] = -1
            BaseSensor._update_sensor_value(self, eventtime)
        except Exception as e:
            logging.error("Error updating json file sensor results: %s", e)
            self.error_state = str(e)
        else:
            self.error_state = None
            for name, value in self.last_measurements.items():
                fdata_list = self.field_info.get(name)
                if fdata_list is None:
                    continue
                for fdata in fdata_list:
                    fdata.tracker.update(value)
        
    async def initialize(self) -> bool:
        await super().initialize()
        try:
            self.error_state = None
            return True
        except Exception as e:
            self.error_state = str(e)
            return False


class SensorLoader:
    __sensor_types: Dict[str, Type[BaseSensor]] = {"JSONFILE": JsonFileSensor}
    
    def __init__(self, config: ConfigHelper) -> None:
        self.server = config.get_server()
        self.sensors: Sensors = self.server.load_component(config, "sensor")
        prefix_sections = config.get_prefix_sections("sensor_custom ")
        for section in prefix_sections:
            cfg = config[section]
            try:
                try:
                    _, name = cfg.get_name().split(maxsplit=1)
                except ValueError:
                    raise cfg.error(f"Invalid section name: {cfg.get_name()}")
                logging.info(f"Configuring sensor: {name}")
                sensor_type: str = cfg.get("type")
                sensor_class: Optional[Type[BaseSensor]] = self.__sensor_types.get(
                    sensor_type.upper(), None
                )
                if sensor_class is None:
                    raise config.error(f"Unsupported sensor type: {sensor_type}")

                self.sensors.sensors[name] = sensor_class(cfg)
            except Exception as e:
                self.server.add_warning(
                    f"Failed to configure sensor [{cfg.get_name()}]\n{e}", exc_info=e
                )
                continue
        
    async def component_init(self) -> None:
        try:
            logging.debug("Initializing SensorLoader component")
        except Exception as e:
            logging.exception(e)


def load_component(config: ConfigHelper) -> SensorLoader:
    return SensorLoader(config)

